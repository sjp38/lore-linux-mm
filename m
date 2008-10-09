Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e38.co.us.ibm.com (8.13.1/8.13.1) with ESMTP id m99CwESw030517
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 06:58:14 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay04.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m99CwjAA183424
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 06:58:45 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m99CwivQ005383
	for <linux-mm@kvack.org>; Thu, 9 Oct 2008 06:58:45 -0600
Subject: Re: [RFC v6][PATCH 0/9] Kernel based checkpoint/restart
From: Dave Hansen <dave@linux.vnet.ibm.com>
In-Reply-To: <20081009124658.GE2952@elte.hu>
References: <1223461197-11513-1-git-send-email-orenl@cs.columbia.edu>
	 <20081009124658.GE2952@elte.hu>
Content-Type: text/plain
Date: Thu, 09 Oct 2008 05:58:42 -0700
Message-Id: <1223557122.11830.14.camel@nimitz>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Ingo Molnar <mingo@elte.hu>
Cc: Oren Laadan <orenl@cs.columbia.edu>, jeremy@goop.org, arnd@arndb.de, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, Alexander Viro <viro@zeniv.linux.org.uk>, "H. Peter Anvin" <hpa@zytor.com>
List-ID: <linux-mm.kvack.org>

On Thu, 2008-10-09 at 14:46 +0200, Ingo Molnar wrote:
> * Oren Laadan <orenl@cs.columbia.edu> wrote:
> 
> > These patches implement basic checkpoint-restart [CR]. This version 
> > (v6) supports basic tasks with simple private memory, and open files 
> > (regular files and directories only). Changes mainly cleanups. See 
> > original announcements below.
> 
> i'm wondering about the following productization aspect: it would be 
> very useful to applications and users if they knew whether it is safe to 
> checkpoint a given app. I.e. whether that app has any state that cannot 
> be stored/restored yet.

Absolutely!

My first inclination was to do this at checkpoint time: detect and tell
users why an app or container can't actually be checkpointed.  But, if I
get you right, you're talking about something that happens more during
the runtime of the app than during the checkpoint.  This sounds like a
wonderful approach to me, and much better than what I was thinking of.

What kind of mechanism do you have in mind?

int sys_remap_file_pages(...)
{
	...
	oh_crap_we_dont_support_this_yet(current);
}

Then the oh_crap..() function sets a task flag or something?

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
