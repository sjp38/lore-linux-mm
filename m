Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx176.postini.com [74.125.245.176])
	by kanga.kvack.org (Postfix) with SMTP id 3CA5B6B0070
	for <linux-mm@kvack.org>; Fri, 28 Sep 2012 18:31:07 -0400 (EDT)
Received: by vbkv13 with SMTP id v13so4628294vbk.14
        for <linux-mm@kvack.org>; Fri, 28 Sep 2012 15:31:06 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <50651D65.5080400@jp.fujitsu.com>
References: <1348724705-23779-1-git-send-email-wency@cn.fujitsu.com>
 <1348724705-23779-2-git-send-email-wency@cn.fujitsu.com> <CAEkdkmVW5wwG4_cy0yHFNVmk2bzAqzo2adRsMn1yHOW9Ex98_g@mail.gmail.com>
 <5064EE3F.3080606@jp.fujitsu.com> <CAHGf_=pDn852sRadnXQMWx3rOTxGLy7876pxk1Ww4oJtkBAZbQ@mail.gmail.com>
 <50651D65.5080400@jp.fujitsu.com>
From: KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>
Date: Fri, 28 Sep 2012 18:30:45 -0400
Message-ID: <CAHGf_=pSEptM-F4+KefqyPeefzH1aC+rkJ13Cg_ssRvA1UyqLw@mail.gmail.com>
Subject: Re: [PATCH 1/4] memory-hotplug: add memory_block_release
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Yasuaki Ishimatsu <isimatu.yasuaki@jp.fujitsu.com>
Cc: Ni zhan Chen <nizhan.chen@gmail.com>, wency@cn.fujitsu.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, rientjes@google.com, liuj97@gmail.com, len.brown@intel.com, benh@kernel.crashing.org, paulus@samba.org, minchan.kim@gmail.com, akpm@linux-foundation.org

> It is not correct. The kobject_put() is prepared against find_memory_block()
> in remove_memory_block() since kobject->kref is incremented in it.
> So release_memory_block() is called by device_unregister() correctly as
> follows:

Ok. Looks good then.
Please rewrite the description more kindly at next spin. Current one
is really really bad.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
