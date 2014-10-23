Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-ig0-f182.google.com (mail-ig0-f182.google.com [209.85.213.182])
	by kanga.kvack.org (Postfix) with ESMTP id 6F0D66B0069
	for <linux-mm@kvack.org>; Thu, 23 Oct 2014 14:52:19 -0400 (EDT)
Received: by mail-ig0-f182.google.com with SMTP id hn18so1877764igb.9
        for <linux-mm@kvack.org>; Thu, 23 Oct 2014 11:52:19 -0700 (PDT)
Received: from relay.sgi.com (relay2.sgi.com. [192.48.180.65])
        by mx.google.com with ESMTP id sb1si3911452igb.9.2014.10.23.11.52.18
        for <linux-mm@kvack.org>;
        Thu, 23 Oct 2014 11:52:18 -0700 (PDT)
Date: Thu, 23 Oct 2014 13:52:46 -0500
From: Alex Thorlton <athorlton@sgi.com>
Subject: Re: [PATCH 0/4] Convert khugepaged to a task_work function
Message-ID: <20141023185246.GF15104@sgi.com>
References: <1414032567-109765-1-git-send-email-athorlton@sgi.com>
 <54494101.6010701@redhat.com>
 <20141023180519.GE15104@sgi.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20141023180519.GE15104@sgi.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: Alex Thorlton <athorlton@sgi.com>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, Bob Liu <lliubbo@gmail.com>, David Rientjes <rientjes@google.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Hugh Dickins <hughd@google.com>, Ingo Molnar <mingo@redhat.com>, Kees Cook <keescook@chromium.org>, "Kirill A. Shutemov" <kirill.shutemov@linux.intel.com>, Mel Gorman <mgorman@suse.de>, Oleg Nesterov <oleg@redhat.com>, Peter Zijlstra <peterz@infradead.org>, Thomas Gleixner <tglx@linutronix.de>, Vladimir Davydov <vdavydov@parallels.com>, linux-kernel@vger.kernel.org

On Thu, Oct 23, 2014 at 01:05:19PM -0500, Alex Thorlton wrote:
> I'll double check everything and do a resend here shortly.

Resend is out there.  It looks like I got this one right (maybe next
time I'll get it on the first try :).  Thanks for pointing out my error,
Rik!

- Alex

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
