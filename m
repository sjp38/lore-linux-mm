Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f172.google.com (mail-wi0-f172.google.com [209.85.212.172])
	by kanga.kvack.org (Postfix) with ESMTP id 474C56B0038
	for <linux-mm@kvack.org>; Tue, 24 Mar 2015 11:27:58 -0400 (EDT)
Received: by wibdy8 with SMTP id dy8so78051870wib.0
        for <linux-mm@kvack.org>; Tue, 24 Mar 2015 08:27:57 -0700 (PDT)
Received: from radon.swed.at (a.ns.miles-group.at. [95.130.255.143])
        by mx.google.com with ESMTPS id di3si24551wid.48.2015.03.24.08.27.56
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 24 Mar 2015 08:27:56 -0700 (PDT)
Message-ID: <55118277.5070909@nod.at>
Date: Tue, 24 Mar 2015 16:27:51 +0100
From: Richard Weinberger <richard@nod.at>
MIME-Version: 1.0
Subject: Re: [RFC PATCH 00/11] an introduction of library operating system
 for Linux (LibOS)
References: <1427202642-1716-1-git-send-email-tazaki@sfc.wide.ad.jp>	<551164ED.5000907@nod.at>	<m2twxacw13.wl@sfc.wide.ad.jp>	<55117565.6080002@nod.at> <m2sicuctb2.wl@sfc.wide.ad.jp>
In-Reply-To: <m2sicuctb2.wl@sfc.wide.ad.jp>
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Hajime Tazaki <tazaki@sfc.wide.ad.jp>
Cc: linux-arch@vger.kernel.org, arnd@arndb.de, corbet@lwn.net, cl@linux.com, penberg@kernel.org, rientjes@google.com, iamjoonsoo.kim@lge.com, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-doc@vger.kernel.org, netdev@vger.kernel.org, linux-mm@kvack.org, jdike@addtoit.com, rusty@rustcorp.com.au, mathieu.lacage@gmail.com

Am 24.03.2015 um 16:24 schrieb Hajime Tazaki:
> I was thinking that such 'architectural' differences in core
> idea (like system call handling, execution model, process
> context design, etc) is better to have a different architecture
> even if some part of the code is similar.
> 
> Isn't it also the same to the other 'hardware-dependent'
> architectures' case like between arm and arm64 ?
> 
> of course I'm also happy to share the code between us,
> especially _pure_ userspace part like (virtual) NIC with
> tap or pcap because we also need that part, but we kept such
> code at an external codebase (i.e., linux-libos-tools).

I'd say you should try hard to re-use/integrate your work in arch/um.
With um we already have an architecture which targets userspace,
having two needs a very good justification.

Thanks,
//richard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
