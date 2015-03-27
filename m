Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f170.google.com (mail-wi0-f170.google.com [209.85.212.170])
	by kanga.kvack.org (Postfix) with ESMTP id D006A6B0032
	for <linux-mm@kvack.org>; Fri, 27 Mar 2015 01:52:14 -0400 (EDT)
Received: by wibbg6 with SMTP id bg6so14267573wib.0
        for <linux-mm@kvack.org>; Thu, 26 Mar 2015 22:52:14 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id ja14si1559962wic.0.2015.03.26.22.52.12
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Thu, 26 Mar 2015 22:52:13 -0700 (PDT)
Message-ID: <5514F004.7030509@nod.at>
Date: Fri, 27 Mar 2015 06:52:04 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at>	<m2sicuctb2.wl@sfc.wide.ad.jp>	<55118277.5070909@nod.at>	<m2bnjhcevt.wl@sfc.wide.ad.jp>	<55133BAF.30301@nod.at>	<m2h9t7bubh.wl@wide.ad.jp>	<5514560A.7040707@nod.at>	<87iodnqfp1.fsf@rustcorp.com.au> <CAMuHMdXYa2K8FH48A8_O-TsfduUC2A2WWD_bHhBgznf6FbN1Zw@mail.gmail.com>
In-Reply-To: <CAMuHMdXYa2K8FH48A8_O-TsfduUC2A2WWD_bHhBgznf6FbN1Zw@mail.gmail.com>
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>, Rusty Russell <rusty@rustcorp.com.au>
Cc: Hajime Tazaki <tazaki@wide.ad.jp>, Linux-Arch <linux-arch@vger.kernel.org>, Arnd Bergmann <arnd@arndb.de>, Jonathan Corbet <corbet@lwn.net>, Christoph Lameter <cl@linux.com>, Pekka Enberg <penberg@kernel.org>, David Rientjes <rientjes@google.com>, Joonsoo Kim <iamjoonsoo.kim@lge.com>, Andrew Morton <akpm@linux-foundation.org>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>, "netdev@vger.kernel.org" <netdev@vger.kernel.org>, Linux MM <linux-mm@kvack.org>, Jeff Dike <jdike@addtoit.com>, mathieu.lacage@gmail.com

Am 27.03.2015 um 04:49 schrieb Geert Uytterhoeven:
> On Fri, Mar 27, 2015 at 4:31 AM, Rusty Russell <rusty@rustcorp.com.au> wrote:
>> Richard Weinberger <richard@nod.at> writes:
>>> This also infers that arch/lib will be broken most of the time as
>>> every time the networking stack references a new symbol it
>>> has to be duplicated into arch/lib.
>>>
>>> But this does not mean that your idea is bad, all I want to say that
>>> I'm not sure whether arch/lib is the right approach.
>>> Maybe Arnd has a better idea.
>>
>> Exactly why I look forward to getting this in-tree.  Jeremy Kerr and I
>> wrote nfsim back in 2005(!) which stubbed around the netfilter
>> infrastructure; with failtest and valgrind it found some nasty bugs.  It
>> was too much hassle to maintain out-of-tree though :(
>>
>> I look forward to a flood of great bugfixes from this work :)
> 
> IIRC, the ability to run UML under valgrind was also one of its key features?
> And that's not limited to networking.

Sadly this feature went never mainline. You needed a rather invading patch
for both Linux and valgrind.

But now with KASan we have a much more powerful feature to find issues.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
