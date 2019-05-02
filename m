Return-Path: <SRS0=Mdb/=TC=kvack.org=owner-linux-mm@kernel.org>
X-Spam-Checker-Version: SpamAssassin 3.4.0 (2014-02-07) on
	aws-us-west-2-korg-lkml-1.web.codeaurora.org
X-Spam-Level: 
X-Spam-Status: No, score=-1.1 required=3.0 tests=DKIM_SIGNED,DKIM_VALID,
	DKIM_VALID_AU,HEADER_FROM_DIFFERENT_DOMAINS,MAILING_LIST_MULTI,SPF_PASS
	autolearn=ham autolearn_force=no version=3.4.0
Received: from mail.kernel.org (mail.kernel.org [198.145.29.99])
	by smtp.lore.kernel.org (Postfix) with ESMTP id 3C687C43219
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:48:06 +0000 (UTC)
Received: from kanga.kvack.org (kanga.kvack.org [205.233.56.17])
	by mail.kernel.org (Postfix) with ESMTP id EC61F20C01
	for <linux-mm@archiver.kernel.org>; Thu,  2 May 2019 16:48:05 +0000 (UTC)
Authentication-Results: mail.kernel.org;
	dkim=pass (2048-bit key) header.d=soleen.com header.i=@soleen.com header.b="SFbei6R/"
DMARC-Filter: OpenDMARC Filter v1.3.2 mail.kernel.org EC61F20C01
Authentication-Results: mail.kernel.org; dmarc=none (p=none dis=none) header.from=soleen.com
Authentication-Results: mail.kernel.org; spf=pass smtp.mailfrom=owner-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix)
	id 88D2F6B0007; Thu,  2 May 2019 12:48:05 -0400 (EDT)
Received: by kanga.kvack.org (Postfix, from userid 40)
	id 83B4E6B0008; Thu,  2 May 2019 12:48:05 -0400 (EDT)
X-Delivered-To: int-list-linux-mm@kvack.org
Received: by kanga.kvack.org (Postfix, from userid 63042)
	id 753136B000A; Thu,  2 May 2019 12:48:05 -0400 (EDT)
X-Delivered-To: linux-mm@kvack.org
Received: from mail-ed1-f72.google.com (mail-ed1-f72.google.com [209.85.208.72])
	by kanga.kvack.org (Postfix) with ESMTP id 297706B0007
	for <linux-mm@kvack.org>; Thu,  2 May 2019 12:48:05 -0400 (EDT)
Received: by mail-ed1-f72.google.com with SMTP id z5so1361996edz.3
        for <linux-mm@kvack.org>; Thu, 02 May 2019 09:48:05 -0700 (PDT)
X-Google-DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=1e100.net; s=20161025;
        h=x-gm-message-state:dkim-signature:mime-version:references
         :in-reply-to:from:date:message-id:subject:to:cc;
        bh=rcAYlClV3WYMLJTodjrLc+GMcN8cBX8qnEYUrl9knag=;
        b=iubGtuOQjw+1bz3pnijyBt+a+gEzR77DHukRQOsv0lrbIJApsqaxe/sfHvF0nxifsY
         F48WauUZ+PatUXzx4Sik7uniTtt8CQwYeP0rem/sVgMp4sW3tzxCkFoT3SmwYQwf2dOB
         Kkivn/arnWC3enuDsFmtX7zpBw1kUlYuh1p4Dz2hq5cG/xNPTQvdzZaOFHpRLNh/OjNK
         lCGeD9UJmsxN4zDm00sdIugublGGPPHTVI6jW6czyay+vvQFIG0ijLKp4GL6/LbciAAN
         QBjZJhDuqTShCE+GcCg29DDsCAy/d5t80GF5pSZ3TTLnsD40hSeSg7xerwu1rt8Kr0hV
         vz7Q==
X-Gm-Message-State: APjAAAWYCmKlg3q4mCllhzimLVXFLn6YxLa6GmoQ+34q35KcJgdh6sVh
	1Qg5hJrro+XKNslh6NQ+p7J0VemndGWauIG6TUHp0Ae57fHiw/aRx9VgX8+HDtFhHwm0pk7BOtQ
	eZyzoxdjeOEs5Zrk0F6Ht0tYGi7KRTavuIRtQWZrIBU2orD2RskG6cdUY+UgzsuYIcQ==
X-Received: by 2002:a05:6402:1610:: with SMTP id f16mr3362263edv.171.1556815684643;
        Thu, 02 May 2019 09:48:04 -0700 (PDT)
X-Received: by 2002:a05:6402:1610:: with SMTP id f16mr3362219edv.171.1556815683986;
        Thu, 02 May 2019 09:48:03 -0700 (PDT)
ARC-Seal: i=1; a=rsa-sha256; t=1556815683; cv=none;
        d=google.com; s=arc-20160816;
        b=HbIGdFLDvBRFNGKEM9pcIvkoWtWMLeCcIAdbyCamJ380lajpuYc9CAuoV2hCDvx5Rl
         iXMsyQ+uUCorEkRHgALXrmpTg8UErK2m32TV/9IX27btvNEuzRKspLJ9BGocWufbgY7O
         CeyPDggAxPaZ00Wd8fCqMqmkNGITMYUQVuD65yG1mWY8s1qVQBLlmuZp3eCkJEQe4tv5
         cM7CcDiipNKVuC3nO328nsJEvzcrulAjQuO0waoI2zM5kve20b49U7gkZsxxOxChSnQS
         EROiI9VuG8xp9z4KmzgA+wiENoXv7CA5c7KohbPKogLJhPjuIgLgGI50YLC1CoYr/OXX
         pCEw==
ARC-Message-Signature: i=1; a=rsa-sha256; c=relaxed/relaxed; d=google.com; s=arc-20160816;
        h=cc:to:subject:message-id:date:from:in-reply-to:references
         :mime-version:dkim-signature;
        bh=rcAYlClV3WYMLJTodjrLc+GMcN8cBX8qnEYUrl9knag=;
        b=TabDLG/MFbQUiz1tYCFYQB0pF8oBIWw6smK0Tr78lh4/jNmOeZGqfw1dC3AFfNsaq/
         xPZNbSM6Li9rpZVhTuPkerm3S+KmsSFu2vNTZxUJdy7f+Dm0cZjw8PN3FnW4BiIWarX6
         ui7QFape0NpD9567LlxSw0+vPwflbggTMGU+uXyceG6uw9pmcLTGAndtaMK0L/5x8AO5
         guktiV3WPLtaDTERIlDLMCMSVCrtjkASpSJO0iRs4JWIKF9zq2foQ8sL9nnKXtOxFcIa
         yuCAqPIUkAWvOqC53swDdyGWT0ctVhlVlgz5Q0zP2w4pOjt9pbxQMUjdp/g/z/BRve/N
         XyVA==
ARC-Authentication-Results: i=1; mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="SFbei6R/";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id t22sor7690504ejf.46.2019.05.02.09.48.03
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Thu, 02 May 2019 09:48:03 -0700 (PDT)
Received-SPF: pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) client-ip=209.85.220.65;
Authentication-Results: mx.google.com;
       dkim=pass header.i=@soleen.com header.s=google header.b="SFbei6R/";
       spf=pass (google.com: domain of pasha.tatashin@soleen.com designates 209.85.220.65 as permitted sender) smtp.mailfrom=pasha.tatashin@soleen.com
DKIM-Signature: v=1; a=rsa-sha256; c=relaxed/relaxed;
        d=soleen.com; s=google;
        h=mime-version:references:in-reply-to:from:date:message-id:subject:to
         :cc;
        bh=rcAYlClV3WYMLJTodjrLc+GMcN8cBX8qnEYUrl9knag=;
        b=SFbei6R/fTHbrGWi+/N+oWim6SS5KPKvxv1TfgMvbJ1pIR8OajbduDS3nFo+mTzicg
         XVys/It0mRnuhAz4kjM8EiZPi2qESa1Ad7BuVtZXc1AhD6SYmi1WTfMnCEAxTNkaT811
         wtR9FZXA8gRcO+e/pbRwpO9NwRgtNQkNQixypgNzB90FxwHw7uDXDkb5kVruMBFHCmWK
         aDFBzlffvUNDnS4Q6tEIHtK+tlNPSguzMFFvyNwltQHrvgbB4cHlbIie4LsGFzTGdkuJ
         7Yg0FEJD9BqWiLWh/W+DXQN7jVHxZsopXpdlsd205vwlCjzC9uuOvIUXoBsgyR88IvAg
         zT4Q==
X-Google-Smtp-Source: APXvYqzbaWRuAebout5s4Iqp5ku1hhP9/l4QkLIfxTg/R4+sKpNKvDwBBtR0sOzGL8kxvPpg3HdXxRKpBddZWv64kk8=
X-Received: by 2002:a17:906:3154:: with SMTP id e20mr2340820eje.263.1556815683667;
 Thu, 02 May 2019 09:48:03 -0700 (PDT)
MIME-Version: 1.0
References: <20190501191846.12634-1-pasha.tatashin@soleen.com>
 <20190501191846.12634-3-pasha.tatashin@soleen.com> <CAPcyv4iPzpP-gzuDtPB2ixd6_uTuO8-YdVSfGw_Dq=igaKuOEg@mail.gmail.com>
In-Reply-To: <CAPcyv4iPzpP-gzuDtPB2ixd6_uTuO8-YdVSfGw_Dq=igaKuOEg@mail.gmail.com>
From: Pavel Tatashin <pasha.tatashin@soleen.com>
Date: Thu, 2 May 2019 12:47:52 -0400
Message-ID: <CA+CK2bB3G_tO04M1eXPdm4b=OojD6QpYkW51YArj6z44RhQo+g@mail.gmail.com>
Subject: Re: [v4 2/2] device-dax: "Hotremove" persistent memory that is used
 like normal RAM
To: Dan Williams <dan.j.williams@intel.com>
Cc: James Morris <jmorris@namei.org>, Sasha Levin <sashal@kernel.org>, 
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, 
	linux-nvdimm <linux-nvdimm@lists.01.org>, Andrew Morton <akpm@linux-foundation.org>, 
	Michal Hocko <mhocko@suse.com>, Dave Hansen <dave.hansen@linux.intel.com>, 
	Keith Busch <keith.busch@intel.com>, Vishal L Verma <vishal.l.verma@intel.com>, 
	Dave Jiang <dave.jiang@intel.com>, Ross Zwisler <zwisler@kernel.org>, 
	Tom Lendacky <thomas.lendacky@amd.com>, "Huang, Ying" <ying.huang@intel.com>, 
	Fengguang Wu <fengguang.wu@intel.com>, Borislav Petkov <bp@suse.de>, Bjorn Helgaas <bhelgaas@google.com>, 
	Yaowei Bai <baiyaowei@cmss.chinamobile.com>, Takashi Iwai <tiwai@suse.de>, 
	=?UTF-8?B?SsOpcsO0bWUgR2xpc3Nl?= <jglisse@redhat.com>, 
	David Hildenbrand <david@redhat.com>
Content-Type: text/plain; charset="UTF-8"
X-Bogosity: Ham, tests=bogofilter, spamicity=0.000000, version=1.2.4
Sender: owner-linux-mm@kvack.org
Precedence: bulk
X-Loop: owner-majordomo@kvack.org
List-ID: <linux-mm.kvack.org>

> Currently the kmem driver can be built as a module, and I don't see a
> need to drop that flexibility. What about wrapping these core
> routines:
>
>     unlock_device_hotplug
>     __remove_memory
>     walk_memory_range
>     lock_device_hotplug
>
> ...into a common exported (gpl) helper like:
>
>     int try_remove_memory(int nid, struct resource *res)
>
> Because as far as I can see there's nothing device-dax specific about
> this "try remove iff offline" functionality outside of looking up the
> related 'struct resource'. The check_devdax_mem_offlined_cb callback
> can be made generic if the callback argument is the resource pointer.

Makes sense, I will do both things that you suggested.

Thank you,
Pasha

