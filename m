Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ie0-f171.google.com (mail-ie0-f171.google.com [209.85.223.171])
	by kanga.kvack.org (Postfix) with ESMTP id 38372900049
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 10:26:40 -0400 (EDT)
Received: by iecsl2 with SMTP id sl2so30639612iec.1
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 07:26:40 -0700 (PDT)
Received: from smtprelay.hostedemail.com (smtprelay0254.hostedemail.com. [216.40.44.254])
        by mx.google.com with ESMTP id f17si4011811ich.32.2015.03.11.07.26.39
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 07:26:39 -0700 (PDT)
Date: Wed, 11 Mar 2015 10:26:36 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: kill kmemcheck
Message-ID: <20150311102636.6b4110a8@gandalf.local.home>
In-Reply-To: <55004595.7020304@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
	<20150311081909.552e2052@grimm.local.home>
	<55003666.3020100@oracle.com>
	<20150311084034.04ce6801@grimm.local.home>
	<55004595.7020304@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

On Wed, 11 Mar 2015 09:39:33 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

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

Yes for both :-)

> 
> There's no real hurry to kill kmemcheck right now, but we do want to stop
> supporting that in favour of KASan.

Understood, but the kernel is suppose to support older compilers.
Perhaps we can keep kmemcheck for now and say it's obsoleted if you
have a newer compiler. Because it will be a while before I upgrade my
compilers. I don't upgrade unless I have a good reason to do so. Not
sure KASan fulfills that requirement.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
