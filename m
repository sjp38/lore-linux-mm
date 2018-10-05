Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pl1-f199.google.com (mail-pl1-f199.google.com [209.85.214.199])
	by kanga.kvack.org (Postfix) with ESMTP id DE4D86B000C
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 17:11:01 -0400 (EDT)
Received: by mail-pl1-f199.google.com with SMTP id v4-v6so12291700plz.21
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 14:11:01 -0700 (PDT)
Received: from mail-sor-f65.google.com (mail-sor-f65.google.com. [209.85.220.65])
        by mx.google.com with SMTPS id l15-v6sor8645970pfb.67.2018.10.05.14.11.00
        for <linux-mm@kvack.org>
        (Google Transport Security);
        Fri, 05 Oct 2018 14:11:00 -0700 (PDT)
Date: Fri, 5 Oct 2018 14:10:58 -0700
From: Joel Fernandes <joel@joelfernandes.org>
Subject: Re: [PATCH RFC] mm: Add an fs-write seal to memfd
Message-ID: <20181005211058.GA193964@joelaf.mtv.corp.google.com>
References: <20181005192727.167933-1-joel@joelfernandes.org>
 <20181005125339.f6febfd3fcfdc69c6f408c50@linux-foundation.org>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005125339.f6febfd3fcfdc69c6f408c50@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Andrew Morton <akpm@linux-foundation.org>
Cc: linux-kernel@vger.kernel.org, kernel-team@android.com, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, gregkh@linuxfoundation.org, Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Oct 05, 2018 at 12:53:39PM -0700, Andrew Morton wrote:
> On Fri,  5 Oct 2018 12:27:27 -0700 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> 
> > To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
> > prevents any future mmap and write syscalls from succeeding while
> > keeping the existing mmap active. The following program shows the seal
> > working in action:
> 
> Please be prepared to create a manpage patch for this one.

Sure, I will do that. thanks,

 - Joel
