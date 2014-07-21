Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f176.google.com (mail-pd0-f176.google.com [209.85.192.176])
	by kanga.kvack.org (Postfix) with ESMTP id 40E526B003C
	for <linux-mm@kvack.org>; Mon, 21 Jul 2014 15:34:21 -0400 (EDT)
Received: by mail-pd0-f176.google.com with SMTP id y10so9629691pdj.7
        for <linux-mm@kvack.org>; Mon, 21 Jul 2014 12:34:20 -0700 (PDT)
Received: from g4t3425.houston.hp.com (g4t3425.houston.hp.com. [15.201.208.53])
        by mx.google.com with ESMTPS id px17si15207115pab.171.2014.07.21.12.34.19
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Mon, 21 Jul 2014 12:34:20 -0700 (PDT)
Message-ID: <1405970672.31850.5.camel@misato.fc.hp.com>
Subject: Re: [RFC PATCH 0/11] Support Write-Through mapping on x86
From: Toshi Kani <toshi.kani@hp.com>
Date: Mon, 21 Jul 2014 13:24:32 -0600
In-Reply-To: <20140721183331.GB13420@laptop.dumpdata.com>
References: <1405452884-25688-1-git-send-email-toshi.kani@hp.com>
	 <53C58A69.3070207@zytor.com> <1405459404.28702.17.camel@misato.fc.hp.com>
	 <03d059f5-b564-4530-9184-f91ca9d5c016@email.android.com>
	 <1405546127.28702.85.camel@misato.fc.hp.com>
	 <1405960298.30151.10.camel@misato.fc.hp.com> <53CD443A.6050804@zytor.com>
	 <1405962993.30151.35.camel@misato.fc.hp.com> <53CD4EB2.5020709@zytor.com>
	 <20140721183331.GB13420@laptop.dumpdata.com>
Content-Type: text/plain; charset="UTF-8"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>
Cc: "H. Peter Anvin" <hpa@zytor.com>, tglx@linutronix.de, mingo@redhat.com, akpm@linux-foundation.org, arnd@arndb.de, plagnioj@jcrosoft.com, tomi.valkeinen@ti.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org, stefan.bader@canonical.com, luto@amacapital.net, airlied@gmail.com, bp@alien8.de

On Mon, 2014-07-21 at 14:33 -0400, Konrad Rzeszutek Wilk wrote:
> On Mon, Jul 21, 2014 at 10:32:34AM -0700, H. Peter Anvin wrote:
> > On 07/21/2014 10:16 AM, Toshi Kani wrote:
 :
> > 
> > >> I would also like a systematic way to deal with the fact
> > >> that Xen (sigh) is stuck with a separate mapping system.
> > >>
> > >> I guess Linux could adopt the Xen mappings if that makes it easier, as
> > >> long as that doesn't have a negative impact on native hardware -- we can
> > >> possibly deal with some older chips not being optimal.  
> > > 
> > > I see.  I agree that supporting the PAT bit is the right direction, but
> > > I do not know how much effort we need.  I will study on this.
> > > 
> > >> However, my thinking has been to have a "reverse PAT" table in memory of memory
> > >> types to encodings, both for regular and large pages.
> > > 
> > > I am not clear about your idea of the "reverse PAT" table.  Would you
> > > care to elaborate?  How is it different from using pte_val() being a
> > > paravirt function on Xen?
> > 
> > First of all, paravirt functions are the root of all evil, and we want
> 
> Here I was thinking to actually put an entry in the MAINTAINERS
> file for me to become the owner of it - as the folks listed there
> are busy with other things.
> 
> The Maintainer of 'All Evil' has an interesting ring to it :-)

:-)

> > to reduce and eliminate them to the utmost level possible.  But yes, we
> > could plumb that up that way if we really need to.
> > 
> > What I'm thinking of is a table which can deal with both the moving PTE
> > bit, Xen, and the scattered encodings by having a small table from types
> > to encodings, and not use the encodings directly until fairly late it
> > the pipe.  I suspect, but I'm not sure, that we would also need the
> > inverse operation.
> 
> Mr Toshi-san,

Oh, you are so polite, Wilk-san. 

> This link: http://xenbits.xen.org/gitweb/?p=xen.git;a=blob;f=xen/arch/x86/hvm/mtrr.c;h=ee18553cdac58dd16836011ee714517fbc16368d;hb=HEAD#l74 might help you in figuring how this can be done.
> 
> Thought I have to say that the code is quite complex so it might
> be more confusing then helpful.

Thanks again for the pointer!  I will take a look.  I used to work on a
paravirt on other OS, but I am pretty much new to Xen.  One more thing
to learn. :-)
-Toshi



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
