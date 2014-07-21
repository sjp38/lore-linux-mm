Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f51.google.com (mail-oa0-f51.google.com [209.85.219.51])
	by kanga.kvack.org (Postfix) with ESMTP id 474046B0087
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 13:43:18 -0400 (EDT)
Received: by mail-oa0-f51.google.com with SMTP id o6so7937759oag.38
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 10:43:18 -0700 (PDT)
Received: from g2t2352.austin.hp.com (g2t2352.austin.hp.com. [15.217.128.51])
        by mx.google.com with ESMTPS id jn8si23633934oeb.8.2014.07.21.10.43.17
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 10:43:17 -0700 (PDT)
Message-ID: <1405964011.31163.1.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 21 Jul 2014 11:33:31 -0600
In-Reply-To: <53CD4EB2.5020709@zytor.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
			 <53C58A69.3070207@zytor.com> <1405459404.28702.17.camel@misato.fc.hp.com>
			 <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com>
			 <1405546127.28702.85.camel@misato.fc.hp.com>
		 <1405960298.30151.10.camel@misato.fc.hp.com> <53CD443A.6050804@zytor.com>
	 <1405962993.30151.35.camel@misato.fc.hp.com> <53CD4EB2.5020709@zytor.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "H. Peter Anvin" <hpa@zytor.com>
Cc: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On Mon, 2014-07-21 at 10:32 -0700, H. Peter Anvin wrote:
> On 07/21/2014 10:16 AM, Toshi Kani wrote:
 :
> >> I would also like a systematic way to deal with the fact
> >> that Xen (sigh) is stuck with a separate mapping system.
> >>
> >> I guess Linux could adopt the Xen mappings if that makes it easier, as
> >> long as that doesn't have a negative impact on native hardware -- we can
> >> possibly deal with some older chips not being optimal.  
> > 
> > I see.  I agree that supporting the PAT bit is the right direction, but
> > I do not know how much effort we need.  I will study on this.
> > 
> >> However, my thinking has been to have a "reverse PAT" table in memory of memory
> >> types to encodings, both for regular and large pages.
> > 
> > I am not clear about your idea of the "reverse PAT" table.  Would you
> > care to elaborate?  How is it different from using pte_val() being a
> > paravirt function on Xen?
> 
> First of all, paravirt functions are the root of all evil, and we want
> to reduce and eliminate them to the utmost level possible.  But yes, we
> could plumb that up that way if we really need to.
> 
> What I'm thinking of is a table which can deal with both the moving PTE
> bit, Xen, and the scattered encodings by having a small table from types
> to encodings, and not use the encodings directly until fairly late it
> the pipe.  I suspect, but I'm not sure, that we would also need the
> inverse operation.

Thanks for the explanation!  I will think about it as well.
-Toshi

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
