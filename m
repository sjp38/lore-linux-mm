Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-io0-f198.google.com (mail-io0-f198.google.com [209.85.223.198])
	by kanga.kvack.org (Postfix) with ESMTP id 022496B002A
	for <linux-mm@kvack.org>; Sat,  7 Apr 2018 16:11:14 -0400 (EDT)
Received: by mail-io0-f198.google.com with SMTP id m17so4360669iod.1
        for <linux-mm@kvack.org>; Sat, 07 Apr 2018 13:11:13 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0079.hostedemail.com. [216.40.44.79])
        by mx.google.com with ESMTPS id d184-v6si8055342ite.132.2018.04.07.13.11.12
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Sat, 07 Apr 2018 13:11:12 -0700 (PDT)
Message-ID: <03c43ed43d0ec3ab42940bfffd4c3778bf5d0f11.camel@perches.com>
Subject: Re: [PATCH 1/3] mm: replace S_IRUGO with 0444
From: Joe Perches <joe@perches.com>
Date: Sat, 07 Apr 2018 13:11:08 -0700
In-Reply-To: <20180407184726.8634-1-paulmcquad@gmail.com>
References: <20180407184726.8634-1-paulmcquad@gmail.com>
Content-Type: text/plain; charset="ISO-8859-1"
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Paul McQuade <paulmcquad@gmail.com>
Cc: konrad.wilk@oracle.com, labbott@redhat.com, gregkh@linuxfoundation.org, akpm@linux-foundation.org, guptap@codeaurora.org, vbabka@suse.cz, mgorman@techsingularity.net, hannes@cmpxchg.org, rientjes@google.com, mhocko@suse.com, rppt@linux.vnet.ibm.com, dave@stgolabs.net, hmclauchlan@fb.com, tglx@linutronix.de, pombredanne@nexb.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org

On Sat, 2018-04-07 at 19:47 +0100, Paul McQuade wrote:
> Fix checkpatch warnings about S_IRUGO being less readable than
> providing the permissions octal as '0444'.

Hey Paul.

I sent a cleanup a couple weeks ago to Andrew Morton for the
same thing.

https://lkml.org/lkml/2018/3/26/638

Andrew said he'd wait until after -rc1 is out.

btw: checkpatch can do this substitution automatically

cheers, Joe
