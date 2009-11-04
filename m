Return-Path: <owner-linux-mm@kvack.org>
Received: from mail190.messagelabs.com (mail190.messagelabs.com [216.82.249.51])
	by kanga.kvack.org (Postfix) with ESMTP id C627F6B0044
	for <linux-mm@kvack.org>; Tue,  3 Nov 2009 21:00:53 -0500 (EST)
Received: from wpaz21.hot.corp.google.com (wpaz21.hot.corp.google.com [172.24.198.85])
	by smtp-out.google.com with ESMTP id nA420ncQ026498
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 18:00:49 -0800
Received: from pwj9 (pwj9.prod.google.com [10.241.219.73])
	by wpaz21.hot.corp.google.com with ESMTP id nA420G6Q008417
	for <linux-mm@kvack.org>; Tue, 3 Nov 2009 18:00:46 -0800
Received: by pwj9 with SMTP id 9so2884267pwj.21
        for <linux-mm@kvack.org>; Tue, 03 Nov 2009 18:00:46 -0800 (PST)
Date: Tue, 3 Nov 2009 18:00:43 -0800 (PST)
From: David Rientjes <rientjes@google.com>
Subject: Re: [patch -mm] mm: slab allocate memory section nodemask for large
 systems
In-Reply-To: <20091102204726.GG5525@ldl.fc.hp.com>
Message-ID: <alpine.DEB.2.00.0911031759350.1187@chino.kir.corp.google.com>
References: <20091022040814.15705.95572.stgit@bob.kio> <20091022041510.15705.5410.stgit@bob.kio> <alpine.DEB.2.00.0910221249030.26631@chino.kir.corp.google.com> <20091027195907.GJ14102@ldl.fc.hp.com> <alpine.DEB.2.00.0910271422090.22335@chino.kir.corp.google.com>
 <20091028083137.GA24140@osiris.boeblingen.de.ibm.com> <alpine.DEB.2.00.0910280159380.7122@chino.kir.corp.google.com> <20091028183905.GF22743@ldl.fc.hp.com> <alpine.DEB.2.00.0910281315370.23279@chino.kir.corp.google.com>
 <20091102204726.GG5525@ldl.fc.hp.com>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
To: Alex Chiang <achiang@hp.com>
Cc: Andrew Morton <akpm@linux-foundation.org>, Heiko Carstens <heiko.carstens@de.ibm.com>, Gary Hade <garyhade@us.ibm.com>, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Badari Pulavarty <pbadari@us.ibm.com>, Martin Schwidefsky <schwidefsky@de.ibm.com>, Ingo Molnar <mingo@elte.hu>
List-ID: <linux-mm.kvack.org>

On Mon, 2 Nov 2009, Alex Chiang wrote:

> Any comments on this patch series?
> 
> Turns out that Kame-san's fear about a memory section spanning
> several nodes on certain architectures (S390) isn't really
> applicable and even if it were, we have code to handle situation
> anyway.
> 
> Kame-san was generally supportive of these convenience symlinks
> although he did not give a formal ACK.
> 
> David has given an ACK on the two patches that do real work, as
> well as supplied the below patch.
> 
> I can respin this series once more, including David's Acked-by:
> and adding his patch if that makes life easier for you.
> 

It's probably in Andrew's queue after getting back from the kernel summit, 
it would be best to wait a week or so.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
