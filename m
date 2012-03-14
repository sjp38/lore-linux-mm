Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx166.postini.com [74.125.245.166])
	by kanga.kvack.org (Postfix) with SMTP id EEEDB6B004A
	for <linux-mm@kvack.org>; Wed, 14 Mar 2012 03:19:51 -0400 (EDT)
Received: by laah2 with SMTP id h2so60707laa.2
        for <linux-mm@kvack.org>; Wed, 14 Mar 2012 00:19:50 -0700 (PDT)
From: Greg Thelen <gthelen@google.com>
Subject: Re: Control page reclaim granularity
References: <20120308161318.GA9904@gmail.com>
Date: Wed, 14 Mar 2012 00:19:43 -0700
Message-ID: <xr93wr6n7ipc.fsf@gthelen.mtv.corp.google.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm <linux-mm@kvack.org>, Zheng Liu <gnehzuil.liu@gmail.com>
Cc: linux-kernel <linux-kernel@vger.kernel.org>, Konstantin Khlebnikov <khlebnikov@openvz.org>

Zheng Liu <gnehzuil.liu@gmail.com> writes:
> Hi Greg,
>
> Sorry, I forgot to say that I don't subscribe linux-mm and linux-kernel
> mailing list.  So please Cc me.
>
> I am glad to receive your reply and I am very interesting for your
> approach.  Actually I am not very familiar with CGroup.  So would you
> please send your patch to me if you can?  Thank you all the same.
>
> Regards,
> Zheng

Sorry for the delay, I had trouble finding my old prototype patch.  The
patch below is based on v2.6.34.  The patch is just an idea not a
complete solution.
