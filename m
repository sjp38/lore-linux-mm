Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-oa0-f44.google.com (mail-oa0-f44.google.com [209.85.219.44])
	by kanga.kvack.org (Postfix) with ESMTP id C22E46B006E
	for <linux-mm@kvack.org>; Wed,  4 Jun 2014 15:35:46 -0400 (EDT)
Received: by mail-oa0-f44.google.com with SMTP id o6so8489856oag.31
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 12:35:46 -0700 (PDT)
Received: from mail-ig0-x22b.google.com (mail-ig0-x22b.google.com [2607:f8b0:4001:c05::22b])
        by mx.google.com with ESMTPS id it15si7600003icc.8.2014.06.04.12.35.45
        for <linux-mm@kvack.org>
        (version=TLSv1 cipher=ECDHE-RSA-RC4-SHA bits=128/128);
        Wed, 04 Jun 2014 12:35:46 -0700 (PDT)
Received: by mail-ig0-f171.google.com with SMTP id c1so6699396igq.10
        for <linux-mm@kvack.org>; Wed, 04 Jun 2014 12:35:45 -0700 (PDT)
MIME-Version: 1.0
In-Reply-To: <20140604191228.GB12375@redhat.com>
References: <20140604182739.GA30340@kroah.com>
	<20140604191228.GB12375@redhat.com>
Date: Wed, 4 Jun 2014 12:35:45 -0700
Message-ID: <CAD2oYtOJbBLrjX9bnNQ5PQnWVdr7ggf=VZWVP3b_KPOPChjd9Q@mail.gmail.com>
Subject: Re: Bad rss-counter is back on 3.14-stable
From: Brandon Philips <brandon.philips@coreos.com>
Content-Type: text/plain; charset=UTF-8
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dave Jones <davej@redhat.com>, Greg KH <gregkh@linuxfoundation.org>, linux-mm@kvack.org, Linux Kernel <linux-kernel@vger.kernel.org>, Brandon Philips <brandon.philips@coreos.com>

On Wed, Jun 4, 2014 at 12:12 PM, Dave Jones <davej@redhat.com> wrote:
> Brandon, what kind of workload is that machine doing ? I wonder if I can
> add something to trinity to make it provoke it.

A really boring database workload (fsync() ~50ms) with a sloowww block
device with btrfs. There are occasional CPU spikes due to expensive
queries.

How can I be more helpful in my workload description?

Thanks,

Brandon

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
