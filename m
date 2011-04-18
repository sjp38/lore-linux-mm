Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 4EA06900086
	for <linux-mm@kvack.org>; Mon, 18 Apr 2011 16:57:12 -0400 (EDT)
Date: Mon, 18 Apr 2011 13:56:37 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH v2] mm: make expand_downwards symmetrical to
 expand_upwards
Message-Id: <20110418135637.5baac204.akpm@linux-foundation.org>
In-Reply-To: <20110418100131.GD8925@tiehlicka.suse.cz>
References: <20110415135144.GE8828@tiehlicka.suse.cz>
	<alpine.LSU.2.00.1104171952040.22679@sister.anvils>
	<20110418100131.GD8925@tiehlicka.suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: Hugh Dickins <hughd@google.com>, linux-mm@kvack.org, LKML <linux-kernel@vger.kernel.org>

On Mon, 18 Apr 2011 12:01:31 +0200
Michal Hocko <mhocko@suse.cz> wrote:

> Currently we have expand_upwards exported while expand_downwards is
> accessible only via expand_stack or expand_stack_downwards.
> 
> check_stack_guard_page is a nice example of the asymmetry. It uses
> expand_stack for VM_GROWSDOWN while expand_upwards is called for
> VM_GROWSUP case.
> 
> Let's clean this up by exporting both functions and make those name
> consistent. Let's use expand_stack_{upwards,downwards} so that we are
> explicit about stack manipulation in the name. expand_stack_downwards
> has to be defined for both CONFIG_STACK_GROWS{UP,DOWN} because
> get_arg_page calls the downwards version in the early process
> initialization phase for growsup configuration.

Has this patch been tested on any stack-grows-upwards architecture?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
