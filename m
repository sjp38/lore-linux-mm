Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pf1-f197.google.com (mail-pf1-f197.google.com [209.85.210.197])
	by kanga.kvack.org (Postfix) with ESMTP id AAB4D6B000D
	for <linux-mm@kvack.org>; Fri,  5 Oct 2018 18:28:36 -0400 (EDT)
Received: by mail-pf1-f197.google.com with SMTP id k1-v6so8550526pfg.13
        for <linux-mm@kvack.org>; Fri, 05 Oct 2018 15:28:36 -0700 (PDT)
Received: from mail.linuxfoundation.org (mail.linuxfoundation.org. [140.211.169.12])
        by mx.google.com with ESMTPS id g38-v6si9677364pgm.193.2018.10.05.15.28.35
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 05 Oct 2018 15:28:35 -0700 (PDT)
Date: Fri, 5 Oct 2018 15:28:20 -0700
From: Greg KH <gregkh@linuxfoundation.org>
Subject: Re: [PATCH RFC] mm: Add an fs-write seal to memfd
Message-ID: <20181005222820.GB13613@kroah.com>
References: <20181005192727.167933-1-joel@joelfernandes.org>
 <20181005125339.f6febfd3fcfdc69c6f408c50@linux-foundation.org>
 <20181005211058.GA193964@joelaf.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20181005211058.GA193964@joelaf.mtv.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Joel Fernandes <joel@joelfernandes.org>
Cc: Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, kernel-team@android.com, jreck@google.com, john.stultz@linaro.org, tkjos@google.com, Al Viro <viro@zeniv.linux.org.uk>, "J. Bruce Fields" <bfields@fieldses.org>, Jeff Layton <jlayton@kernel.org>, Khalid Aziz <khalid.aziz@oracle.com>, linux-fsdevel@vger.kernel.org, linux-mm@kvack.org, Mike Kravetz <mike.kravetz@oracle.com>

On Fri, Oct 05, 2018 at 02:10:58PM -0700, Joel Fernandes wrote:
> On Fri, Oct 05, 2018 at 12:53:39PM -0700, Andrew Morton wrote:
> > On Fri,  5 Oct 2018 12:27:27 -0700 "Joel Fernandes (Google)" <joel@joelfernandes.org> wrote:
> > 
> > > To support the usecase, this patch adds a new F_SEAL_FS_WRITE seal which
> > > prevents any future mmap and write syscalls from succeeding while
> > > keeping the existing mmap active. The following program shows the seal
> > > working in action:
> > 
> > Please be prepared to create a manpage patch for this one.
> 
> Sure, I will do that. thanks,

And a test case to the in-kernel memfd tests would be appreciated.

thanks,

greg k-h
