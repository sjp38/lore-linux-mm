Received: from spaceape8.eur.corp.google.com (spaceape8.eur.corp.google.com [172.28.16.142])
	by smtp-out.google.com with ESMTP id l56JoiLe026688
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 20:50:44 +0100
Received: from py-out-1112.google.com (pyia29.prod.google.com [10.34.253.29])
	by spaceape8.eur.corp.google.com with ESMTP id l56JnTH0001527
	for <linux-mm@kvack.org>; Wed, 6 Jun 2007 20:50:42 +0100
Received: by py-out-1112.google.com with SMTP id a29so470190pyi
        for <linux-mm@kvack.org>; Wed, 06 Jun 2007 12:50:42 -0700 (PDT)
Message-ID: <65dd6fd50706061250l7378ec38gf86c984fe4e00b86@mail.gmail.com>
Date: Wed, 6 Jun 2007 12:50:42 -0700
From: "Ollie Wild" <aaw@google.com>
Subject: Re: [PATCH 3/4] mm: move_page_tables{,_up}
In-Reply-To: <1181157134.5676.28.camel@lappy>
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
References: <20070605150523.786600000@chello.nl>
	 <20070605151203.738393000@chello.nl>
	 <65dd6fd50706061206y558e7f90t3740424fae7bdc9c@mail.gmail.com>
	 <1181157134.5676.28.camel@lappy>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: linux-kernel@vger.kernel.org, parisc-linux@lists.parisc-linux.org, linux-mm@kvack.org, linux-arch@vger.kernel.org, Andrew Morton <akpm@osdl.org>, Ingo Molnar <mingo@elte.hu>, Andi Kleen <ak@suse.de>
List-ID: <linux-mm.kvack.org>

On 6/6/07, Peter Zijlstra <a.p.zijlstra@chello.nl> wrote:
> PA-RISC will still need it, right?

Originally, I thought since the PA-RISC stack grows up, we'd want to
place the stack at the bottom of memory and have copy_strings() and
friends work in the opposite direction.  It turns out, though, that
this ends up being way more headache than it's worth, so I just
manually grow the stack down with expand_downwards().

Ollie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
