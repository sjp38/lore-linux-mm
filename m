Return-Path: <SRS0=K2Kt=QQ=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.0 required=3.0 tests=HEADER_FROM_DIFFERENT_DOMAINS,
	HTML_MESSAGE,MAILING_LIST_MULTI,SPF_PASS autolearn=ham autolearn_force=no
	version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 61EACC282C4
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 11:00:11 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id F251E21773
	for <linux-mm@archiver.kernel.org>; Sat,  9 Feb 2019 11:00:10 +0000 (UTC)
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org F251E21773
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=inria.fr
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 4933D8E00C6; Sat,  9 Feb 2019 06:00:10 -0500 (EST)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 41C788E00C5; Sat,  9 Feb 2019 06:00:10 -0500 (EST)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 295FD8E00C6; Sat,  9 Feb 2019 06:00:10 -0500 (EST)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-wm1-f72.google.com (mail-wm1-f72.google.com [209.85.128.72])
	by kanga.kvack.org (Postfix) with ESMTP id C20C78E00C5
	for <linux-mm@kvack.org>; Sat,  9 Feb 2019 06:00:09 -0500 (EST)
Received: by mail-wm1-f72.google.com with SMTP id l18so2409981wmh.4
        for <linux-mm@kvack.org>; Sat, 09 Feb 2019 03:00:09 -0800 (PST)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-original-authentication-results:x-gm-message-state:subject:to:cc
         :references:from:openpgp:autocrypt:message-id:date:user-agent
         :mime-version:in-reply-to:content-language;
        bh=qkfEKE0briYjP4CKwnxFtkfE1quBhGAIRN4a3rMqir0=;
        b=SKCCJmOzrtQY/vIckwoWtyS11valDbbpjzfacM3LJyRnPWwxgF3bFRYfoffVv6WKvl
         wXG3d892b6h2ElWiav7IL9wkWkvMlif6yqFA1Vbfr70a14nAQdTKOwLOMzCv4pKFM667
         XIEqfnPl+IdAGxP6JeoBDfFHc7jtWYy2XeFfbYklp0CdyHtOFxqdiD2gkWj6biqNBKEC
         N7e/s/U5bGXTSKchsaIOHu6C08ZHorf7JDoOysta/AvjSgjMN1t388npMElJ300oDCpm
         WHvT5tt63EZ6ouEoZRwpWK3BfXNfMoT9Id6NSVlAZB4PGz44eWdQlbwXJb/cQ6+DC0pw
         PztA==
X-Original-Authentication-Results: mx.google.com;       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-Gm-Message-State: AHQUAuakV3vo4navvtQI0eRNRnrsZBVScxa4HVlpV6jdVYxl/JEcDzBM
	kwGY80Z+DuconJ2yznWeEVt+Bwm9/QSXfopuy0F6yYigGoM3uXTgpIXRvVFBTfESzUGFhEqY4YG
	j4lNGZzx07My9sJi8FboozpUfgBjrkp9bozxURs2vikDvQxvHwrDqGgqY7o1u1vNGSQ==
X-Received: by 2002:a1c:a4c4:: with SMTP id n187mr2467783wme.15.1549710009164;
        Sat, 09 Feb 2019 03:00:09 -0800 (PST)
X-Google-Smtp-Source: AHgI3IbDCJXco3L8fBQzaOwDSiubWsoT/5+uLQXdYLmhx23VnZFUteZaFRxWStHb7+NEOaLtj/Hx
X-Received: by 2002:a1c:a4c4:: with SMTP id n187mr2467711wme.15.1549710007992;
        Sat, 09 Feb 2019 03:00:07 -0800 (PST)
ARC-Seal: i=1; a=rsa-sha256; t=1549710007; cv=none;
        d=google.com; s=arc-20160816;
        b=napJbtT+UBnfj4e4NTRxz1sZtcGAbcqiK3DREf/KQswI+7nXa6+xnNj2w0MAkxR1Zz
         nZWTboCO9Y503gyugtHgdlbL9avQ8SPpEOTMDwV0EbXCMJWTK17D3u/GfNI6H29+qCJB
         QGOlUsGPf3+cXqxGjNgAk2UuJsnuR9bHZIO+ICCt25sH4PZoIEAqorMj/rzaeCT2G0Tx
         /Kyg3cGGlJuiMwfALXc1ZmZlK3XNVfqukGPUKnPFEQT2PJE5yraL0tGrkp4Q+MWrTbtC
         2lcaT7ND/BIRb/T+zhs0RSGI74SvHqMWVv4TWRVgpVAAjanp02q3CE9B92eqQtKrMWtH
         cn9A==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=content-language:in-reply-to:mime-version:user-agent:date
         :message-id:autocrypt:openpgp:from:references:cc:to:subject;
        bh=qkfEKE0briYjP4CKwnxFtkfE1quBhGAIRN4a3rMqir0=;
        b=vH3jP8AW5pjQXF+GrhbWnocGpCIJAO+NMMciFgKcj5CCsZonoUs1kerBfiQyTxW74e
         YjvxQCHQVgGIYYOeOB0PB9UEim2aqiZq+jv4AuznzudfULFezZRJ1fIJzSRVSI8Zhuyk
         EhvBLdVM5d+RciGwGzBhsXe+UJAM6NPGX+xAXK3TK2qAim8w/57jS98/Yoq732CN8S9v
         mNMoQvrEoGHM4vfd3QPg1zEFSVSdwyeMFJ4Req3HGuXl5WgYFTycWO2psdTW97FDh2v8
         DUGENKyWplAPgGU/7lI+RDVCtge3bPGvfVldpeKSri3++wdkdV8VP9+BtC0GVATvVRTX
         UpXg==
ARC-Authentication-Results: i=1; mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
Received: from mail3-relais-sop.national.inria.fr (mail3-relais-sop.national.inria.fr. [192.134.164.104])
        by mx.google.com with ESMTPS id z5si2981460wrw.69.2019.02.09.03.00.07
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 09 Feb 2019 03:00:07 -0800 (PST)
Received-SPF: pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) client-ip=192.134.164.104;
Authentication-Results: mx.google.com;
       spf=pass (google.com: domain of brice.goglin@inria.fr designates 192.134.164.104 as permitted sender) smtp.mailfrom=Brice.Goglin@inria.fr
X-IronPort-AV: E=Sophos;i="5.58,351,1544482800"; 
   d="scan'208,217";a="295608386"
Received: from 91-160-5-165.subs.proxad.net (HELO [192.168.44.23]) ([91.160.5.165])
  by mail3-relais-sop.national.inria.fr with ESMTP/TLS/AES128-SHA; 09 Feb 2019 12:00:06 +0100
Subject: Re: [PATCH 5/5] dax: "Hotplug" persistent memory for use like normal
 RAM
To: Dave Hansen <dave.hansen@linux.intel.com>, linux-kernel@vger.kernel.org
Cc: thomas.lendacky@amd.com, mhocko@suse.com, linux-nvdimm@lists.01.org,
 tiwai@suse.de, ying.huang@intel.com, linux-mm@kvack.org, jglisse@redhat.com,
 bp@suse.de, baiyaowei@cmss.chinamobile.com, zwisler@kernel.org,
 bhelgaas@google.com, fengguang.wu@intel.com, akpm@linux-foundation.org
References: <20190124231441.37A4A305@viggo.jf.intel.com>
 <20190124231448.E102D18E@viggo.jf.intel.com>
From: Brice Goglin <Brice.Goglin@inria.fr>
Openpgp: preference=signencrypt
Autocrypt: addr=Brice.Goglin@inria.fr; prefer-encrypt=mutual; keydata=
 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
Message-ID: <c4c6aca8-6ee8-be10-65ae-4cbe0aa03bfb@inria.fr>
Date: Sat, 9 Feb 2019 12:00:05 +0100
User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:60.0) Gecko/20100101
 Thunderbird/60.4.0
MIME-Version: 1.0
In-Reply-To: <20190124231448.E102D18E@viggo.jf.intel.com>
Content-Type: multipart/alternative;
 boundary="------------B1FBBAC4595CC6A4AB516193"
Content-Language: en-US
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------B1FBBAC4595CC6A4AB516193
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

Le 25/01/2019 à 00:14, Dave Hansen a écrit :
> From: Dave Hansen <dave.hansen@linux.intel.com>
>
> This is intended for use with NVDIMMs that are physically persistent
> (physically like flash) so that they can be used as a cost-effective
> RAM replacement.  Intel Optane DC persistent memory is one
> implementation of this kind of NVDIMM.
>
> Currently, a persistent memory region is "owned" by a device driver,
> either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
> allow applications to explicitly use persistent memory, generally
> by being modified to use special, new libraries. (DIMM-based
> persistent memory hardware/software is described in great detail
> here: Documentation/nvdimm/nvdimm.txt).
>
> However, this limits persistent memory use to applications which
> *have* been modified.  To make it more broadly usable, this driver
> "hotplugs" memory into the kernel, to be managed and used just like
> normal RAM would be.
>
> To make this work, management software must remove the device from
> being controlled by the "Device DAX" infrastructure:
>
> 	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/remove_id
> 	echo -n dax0.0 > /sys/bus/dax/drivers/device_dax/unbind


Hello Dave

I am trying to use these patches (on top on Dan's nvdimm-pending branch
with Keith's HMAT patches). Writing to remove_id just hangs. echo never
returns, it uses 100% CPU and I can't kill it.

[ 5468.744898] bash            R  running task        0 21419  21416 0x00000080
[ 5468.744899] Call Trace:
[ 5468.744902]  ? vsnprintf+0x372/0x4e0
[ 5468.744904]  ? klist_next+0x79/0xe0
[ 5468.744905]  ? sprintf+0x56/0x80
[ 5468.744907]  ? bus_for_each_dev+0x8a/0xc0
[ 5468.744911]  ? do_id_store+0xe8/0x1e0
[ 5468.744914]  ? _cond_resched+0x15/0x30
[ 5468.744915]  ? __kmalloc+0x17f/0x200
[ 5468.744918]  ? kernfs_fop_write+0x83/0x190
[ 5468.744918]  ? __vfs_write+0x36/0x1b0
[ 5468.744919]  ? selinux_file_permission+0xe1/0x130
[ 5468.744921]  ? security_file_permission+0x36/0x100
[ 5468.744922]  ? vfs_write+0xad/0x1b0
[ 5468.744922]  ? ksys_write+0x52/0xc0
[ 5468.744924]  ? do_syscall_64+0x5b/0x180
[ 5468.744927]  ? entry_SYSCALL_64_after_hwframe+0x44/0xa9

CONFIG_NVDIMM_DAX=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_DEV_DAX_KMEM=m
CONFIG_DEV_DAX_PMEM_COMPAT=m
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y

  {
    "dev":"namespace0.0",
    "mode":"devdax",
    "map":"dev",
    "size":1598128390144,
    "uuid":"7046a749-477f-4690-9b3c-a640a1aa44f1",
    "chardev":"dax0.0"
  }


I've used your patches on fake hardware (memmap=xx!yy) with an older
nvdimm-pending branch (without Keith's patches). It worked fine. This
time I am running on real Intel hardware. Any idea where to look ?

Thanks

Brice



--------------B1FBBAC4595CC6A4AB516193
Content-Type: text/html; charset=utf-8
Content-Transfer-Encoding: 8bit

<html>
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  </head>
  <body text="#000000" bgcolor="#FFFFFF">
    <div class="moz-cite-prefix">Le 25/01/2019 à 00:14, Dave Hansen a
      écrit :<br>
    </div>
    <blockquote type="cite"
      cite="mid:20190124231448.E102D18E@viggo.jf.intel.com">
      <pre class="moz-quote-pre" wrap="">
From: Dave Hansen <a class="moz-txt-link-rfc2396E" href="mailto:dave.hansen@linux.intel.com">&lt;dave.hansen@linux.intel.com&gt;</a>

This is intended for use with NVDIMMs that are physically persistent
(physically like flash) so that they can be used as a cost-effective
RAM replacement.  Intel Optane DC persistent memory is one
implementation of this kind of NVDIMM.

Currently, a persistent memory region is "owned" by a device driver,
either the "Direct DAX" or "Filesystem DAX" drivers.  These drivers
allow applications to explicitly use persistent memory, generally
by being modified to use special, new libraries. (DIMM-based
persistent memory hardware/software is described in great detail
here: Documentation/nvdimm/nvdimm.txt).

However, this limits persistent memory use to applications which
*have* been modified.  To make it more broadly usable, this driver
"hotplugs" memory into the kernel, to be managed and used just like
normal RAM would be.

To make this work, management software must remove the device from
being controlled by the "Device DAX" infrastructure:

	echo -n dax0.0 &gt; /sys/bus/dax/drivers/device_dax/remove_id
	echo -n dax0.0 &gt; /sys/bus/dax/drivers/device_dax/unbind
</pre>
    </blockquote>
    <p><br>
    </p>
    <p>Hello Dave</p>
    <p>I am trying to use these patches (on top on Dan's nvdimm-pending
      branch with Keith's HMAT patches). Writing to remove_id just
      hangs. echo never returns, it uses 100% CPU and I can't kill it.</p>
    <pre>[ 5468.744898] bash            R  running task        0 21419  21416 0x00000080
[ 5468.744899] Call Trace:
[ 5468.744902]  ? vsnprintf+0x372/0x4e0
[ 5468.744904]  ? klist_next+0x79/0xe0
[ 5468.744905]  ? sprintf+0x56/0x80
[ 5468.744907]  ? bus_for_each_dev+0x8a/0xc0
[ 5468.744911]  ? do_id_store+0xe8/0x1e0
[ 5468.744914]  ? _cond_resched+0x15/0x30
[ 5468.744915]  ? __kmalloc+0x17f/0x200
[ 5468.744918]  ? kernfs_fop_write+0x83/0x190
[ 5468.744918]  ? __vfs_write+0x36/0x1b0
[ 5468.744919]  ? selinux_file_permission+0xe1/0x130
[ 5468.744921]  ? security_file_permission+0x36/0x100
[ 5468.744922]  ? vfs_write+0xad/0x1b0
[ 5468.744922]  ? ksys_write+0x52/0xc0
[ 5468.744924]  ? do_syscall_64+0x5b/0x180
[ 5468.744927]  ? entry_SYSCALL_64_after_hwframe+0x44/0xa9

CONFIG_NVDIMM_DAX=y
CONFIG_DAX_DRIVER=y
CONFIG_DAX=y
CONFIG_DEV_DAX=m
CONFIG_DEV_DAX_PMEM=m
CONFIG_DEV_DAX_KMEM=m
CONFIG_DEV_DAX_PMEM_COMPAT=m
CONFIG_FS_DAX=y
CONFIG_FS_DAX_PMD=y

  {
    "dev":"namespace0.0",
    "mode":"devdax",
    "map":"dev",
    "size":1598128390144,
    "uuid":"7046a749-477f-4690-9b3c-a640a1aa44f1",
    "chardev":"dax0.0"
  }


</pre>
    <p>I've used your patches on fake hardware (memmap=xx!yy) with an
      older nvdimm-pending branch (without Keith's patches). It worked
      fine. This time I am running on real Intel hardware. Any idea
      where to look ?</p>
    <p>Thanks</p>
    <p>Brice</p>
    <p><br>
    </p>
  </body>
</html>

--------------B1FBBAC4595CC6A4AB516193--

