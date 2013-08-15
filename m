Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx129.postini.com [74.125.245.129])
	by kanga.kvack.org (Postfix) with SMTP id B78376B0032
	for <linux-mm@kvack.org>; Thu, 15 Aug 2013 05:01:06 -0400 (EDT)
From: Gergely Risko <gergely@risko.hu>
Subject: Re: [PATCH] mm: memcontrol: fix handling of swapaccount parameter
References: <1376486495-21457-1-git-send-email-gergely@risko.hu>
	<20130814183604.GE24033@dhcp22.suse.cz>
	<20130814184956.GF24033@dhcp22.suse.cz>
	<87ioz855o0.fsf@gergely.risko.hu>
	<20130815074714.GA27864@dhcp22.suse.cz>
Date: Thu, 15 Aug 2013 11:01:01 +0200
In-Reply-To: <20130815074714.GA27864@dhcp22.suse.cz> (Michal Hocko's message
	of "Thu, 15 Aug 2013 09:47:14 +0200")
Message-ID: <87eh9v5nw2.fsf@gergely.risko.hu>
MIME-Version: 1.0
Content-Type: text/plain
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: cgroups@vger.kernel.org, linux-mm@kvack.org, linux-kernel@vger.kernel.org, torvalds@linux-foundation.org, Andrew Morton <akpm@linux-foundation.org>

On Thu, 15 Aug 2013 09:47:14 +0200, Michal Hocko <mhocko@suse.cz> writes:

> Ohh, I have totally missed those left-overs. I would rather fix the doc
> than reintroduce the handling without any value.

Okay, fine with me, thanks for fixing these left-overs!

Gergely

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
