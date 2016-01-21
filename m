Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f53.google.com (mail-wm0-f53.google.com [74.125.82.53])
	by kanga.kvack.org (Postfix) with ESMTP id 618326B0009
	for <linux-mm@kvack.org>; Thu, 21 Jan 2016 15:57:12 -0500 (EST)
Received: by mail-wm0-f53.google.com with SMTP id r129so188267817wmr.0
        for <linux-mm@kvack.org>; Thu, 21 Jan 2016 12:57:12 -0800 (PST)
Received: from gum.cmpxchg.org (gum.cmpxchg.org. [85.214.110.215])
        by mx.google.com with ESMTPS id z77si1683wmz.103.2016.01.21.12.57.11
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 21 Jan 2016 12:57:11 -0800 (PST)
Date: Thu, 21 Jan 2016 15:56:28 -0500
From: Johannes Weiner <hannes@cmpxchg.org>
Subject: Re: [PATCH] net: sock: remove dead cgroup methods from struct proto
Message-ID: <20160121205628.GA14909@cmpxchg.org>
References: <1453402871-2548-1-git-send-email-hannes@cmpxchg.org>
 <56A131D7.4040102@cogentembedded.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <56A131D7.4040102@cogentembedded.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org

On Thu, Jan 21, 2016 at 10:30:31PM +0300, Sergei Shtylyov wrote:
> Hello.
> 
> On 01/21/2016 10:01 PM, Johannes Weiner wrote:
> 
> >The cgroup methods are no longer used after baac50b ("net:
> 
>    12-digit ID is now enforced by scripts/checkpatch.pl.

Thanks for the headsup, that hasn't made it into my copy of
checkpatch.pl yet.

Here is the updated patch:
