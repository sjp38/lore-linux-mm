Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-pd0-f182.google.com (mail-pd0-f182.google.com [209.85.192.182])
	by kanga.kvack.org (Postfix) with ESMTP id 2B3D390002E
	for <linux-mm@kvack.org>; Wed, 11 Mar 2015 08:39:44 -0400 (EDT)
Received: by pdjy10 with SMTP id y10so10905063pdj.12
        for <linux-mm@kvack.org>; Wed, 11 Mar 2015 05:39:43 -0700 (PDT)
Received: from cdptpa-oedge-vip.email.rr.com (cdptpa-outbound-snat.email.rr.com. [107.14.166.226])
        by mx.google.com with ESMTP id km1si7180939pab.14.2015.03.11.05.39.42
        for <linux-mm@kvack.org>;
        Wed, 11 Mar 2015 05:39:43 -0700 (PDT)
Date: Wed, 11 Mar 2015 08:40:34 -0400
From: Steven Rostedt <rostedt@goodmis.org>
Subject: Re: [PATCH] mm: kill kmemcheck
Message-ID: <20150311084034.04ce6801@grimm.local.home>
In-Reply-To: <55003666.3020100@oracle.com>
References: <1426074547-21888-1-git-send-email-sasha.levin@oracle.com>
	<20150311081909.552e2052@grimm.local.home>
	<55003666.3020100@oracle.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Sasha Levin <sasha.levin@oracle.com>
Cc: LKML <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, netdev@vger.kernel.org, linux-arch@vger.kernel.org, linux-fsdevel@vger.kernel.org, linux-crypto@vger.kernel.org

On Wed, 11 Mar 2015 08:34:46 -0400
Sasha Levin <sasha.levin@oracle.com> wrote:

> Fair enough. We knew there are existing kmemcheck users, but KASan should be
> superior both in performance and the scope of bugs it finds. It also shouldn't
> impose new limitations beyond requiring gcc 4.9.2+.
>

Ouch! OK, then I can't use it. I'm currently compiling with gcc 4.6.3.

It will be a while before I upgrade my build farm to something newer.

-- Steve

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
