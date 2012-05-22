Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx170.postini.com [74.125.245.170])
	by kanga.kvack.org (Postfix) with SMTP id 1CFB66B00E7
	for <linux-mm@kvack.org>; Tue, 22 May 2012 19:29:48 -0400 (EDT)
Date: Tue, 22 May 2012 16:29:46 -0700
From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 3.4-rc7: BUG: Bad rss-counter state mm:ffff88040b56f800 idx:1
 val:-59
Message-Id: <20120522162946.2afcdb50.akpm@linux-foundation.org>
In-Reply-To: <20120522162835.c193c8e0.akpm@linux-foundation.org>
References: <4FBC1618.5010408@fold.natur.cuni.cz>
	<20120522162835.c193c8e0.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Martin Mokrejs <mmokrejs@fold.natur.cuni.cz>, LKML <linux-kernel@vger.kernel.org>, khlebnikov@openvz.org, markus@trippelsdorf.de, hughd@google.com, kamezawa.hiroyu@jp.fujitsu.com, oleg@redhat.com, Michal Hocko <mhocko@suse.cz>, linux-mm@kvack.org

On Tue, 22 May 2012 16:28:35 -0700
Andrew Morton <akpm@linux-foundation.org> wrote:

> I notice that I don't have this tagged for -stable backporting.  That
> seems wrong.  Konstantin, do we know for how long this bug has been in
> there?

Also, I have a note here that Oleg was unhappy with the patch.  Oleg
happiness is important.  Has he cheered up yet?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
