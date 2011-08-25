Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id 71B866B016A
	for <linux-mm@kvack.org>; Thu, 25 Aug 2011 17:01:36 -0400 (EDT)
From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [PATCH] oom: skip frozen tasks
Date: Thu, 25 Aug 2011 23:03:17 +0200
References: <20110823073101.6426.77745.stgit@zurg> <20110825091920.GA22564@tiehlicka.suse.cz> <20110825151818.GA4003@redhat.com>
In-Reply-To: <20110825151818.GA4003@redhat.com>
MIME-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Message-Id: <201108252303.17446.rjw@sisk.pl>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Oleg Nesterov <oleg@redhat.com>
Cc: Michal Hocko <mhocko@suse.cz>, David Rientjes <rientjes@google.com>, Konstantin Khlebnikov <khlebnikov@openvz.org>, linux-mm@kvack.org, Andrew Morton <akpm@linux-foundation.org>, linux-kernel@vger.kernel.org, KOSAKI Motohiro <kosaki.motohiro@jp.fujitsu.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>

On Thursday, August 25, 2011, Oleg Nesterov wrote:
> On 08/25, Michal Hocko wrote:
> >
> > On Wed 24-08-11 12:31:26, David Rientjes wrote:
> > >
> > > That's obviously false since we call oom_killer_disable() in 
> > > freeze_processes() to disable the oom killer from ever being called in the 
> > > first place, so this is something you need to resolve with Rafael before 
> > > you cause more machines to panic.
> >
> > I didn't mean suspend/resume path (that is protected by oom_killer_disabled)
> > so the patch doesn't make any change.
> 
> Confused... freeze_processes() does try_to_freeze_tasks() before
> oom_killer_disable() ?

Yes, it does.

Thanks,
Rafael

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
