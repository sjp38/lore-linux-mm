Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-qg0-f42.google.com (mail-qg0-f42.google.com [209.85.192.42])
	by kanga.kvack.org (Postfix) with ESMTP id 0033D6B0080
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 18:22:59 -0400 (EDT)
Received: by mail-qg0-f42.google.com with SMTP id q107so274628qgd.15
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 15:22:59 -0700 (PDT)
Received: from mx1.redhat.com (mx1.redhat.com. [209.132.183.28])
        by mx.google.com with ESMTP id y89si5645618qgd.32.2014.06.04.15.22.58
        for <linux-mm@kvack.org>;
        Wed, 04 Jun 2014 15:22:58 -0700 (PDT)
Date: Wed, 4 Jun 2014 18:22:50 -0400
From: Dave Jones <davej@redhat.com>
Subject: Re: Bad rss-counter is back on 3.14-stable
Message-ID: <20140604222250.GA12927@redhat.com>
References: <20140604182739.GA30340@kroah.com>
 <20140604191228.GB12375@redhat.com>
 <CAD2oYtOJbBLrjX9bnNQ5PQnWVdr7ggf=VZWVP3b_KPOPChjd9Q@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAD2oYtOJbBLrjX9bnNQ5PQnWVdr7ggf=VZWVP3b_KPOPChjd9Q@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Brandon Philips <brandon.philips@coreos.com>
Cc: Greg KH <gregkh@linuxfoundation.org>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>

On Wed, Jun 04, 2014 at 12:35:45PM -0700, Brandon Philips wrote:
 > On Wed, Jun 4, 2014 at 12:12 PM, Dave Jones <davej@redhat.com> wrote:
 > > Brandon, what kind of workload is that machine doing ? I wonder if I can
 > > add something to trinity to make it provoke it.
 > 
 > A really boring database workload (fsync() ~50ms) with a sloowww block
 > device with btrfs. There are occasional CPU spikes due to expensive
 > queries.
 > 
 > How can I be more helpful in my workload description?

I feared it would be something like a database. Trying to replicate
things seen under those workloads always seems to be challenging,
in part due to the system specific setups they seem to have.

I wonder if any of the benchmarking apps we have do a realistic
representation of what modern databases do. It might be a fun project
to take something like that and extend it to do random queries.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
