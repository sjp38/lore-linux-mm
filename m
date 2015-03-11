Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wi0-f182.google.com (mail-wi0-f182.google.com [209.85.212.182])
	by kanga.kvack.org (Postfix) with ESMTP id D86C4900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 10:23:30 -0400 (EDT)
Received: by wibbs8 with SMTP id bs8so12199177wib.4
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 07:23:30 -0700 (PDT)
Received: from arcturus.aphlor.org (arcturus.ipv6.aphlor.org. [2a03:9800:10:4a::2])
        by mx.google.com with ESMTPS id ez12si30538253wid.0.2015.03.11.07.23.28
        for <linux-mm@kvack.org>
        (version=TLSv1.2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 11 Mar 2015 07:23:29 -0700 (PDT)
Date: Wed, 11 Mar 2015 10:23:21 -0400
From: Dave Jones <davej@codemonkey.org.uk>
Subject: Re: [PATCH] mm: kill kmemcheck
Message-ID: <20150311142321.GA1143@codemonkey.org.uk>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
 <20150311081909.552e2052@grimm.local.home>
 <55003666.3020100@oracle.com>
 <20150311084034.04ce6801@grimm.local.home>
 <55004595.7020304@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <55004595.7020304@oracle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: Steven Rostedt <rostedt@goodmis.org>, LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

On Wed, Mar 11, 2015 at 09:39:33AM -0400, Sasha Levin wrote:
 > On 03/11/2015 08:40 AM, Steven Rostedt wrote:
 > > On Wed, 11 Mar 2015 08:34:46 -0400
 > > Sasha Levin <sasha.levin@oracle.com> wrote:
 > > 
 > >> > Fair enough. We knew there are existing kmemcheck users, but KASan should be
 > >> > superior both in performance and the scope of bugs it finds. It also shouldn't
 > >> > impose new limitations beyond requiring gcc 4.9.2+.
 > >> >
 > > Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.
 > > 
 > > It will be a while before I upgrade my build farm to something newer.
 > 
 > Are you actually compiling new kernels with 4.6.3, or are you using older
 > kernels as well?
 > 
 > There's no real hurry to kill kmemcheck right now, but we do want to stop
 > supporting that in favour of KASan.
 
Another question is "is kmemcheck actually finding anything right now?"
I've personally not hit anything with it in quite a while.

	Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
