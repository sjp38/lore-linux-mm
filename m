Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx193.postini.com [74.125.245.193])
	by kanga.kvack.org (Postfix) with SMTP id C4D2C6B004D
	for <linux-mm@kvack.org>; Thu, 15 Mar 2012 07:13:51 -0400 (EDT)
Message-ID: <1331810014.18960.172.camel@twins>
Subject: Re: [PATCH v2 02/13] memcg: Kernel memory accounting infrastructure.
From: Peter Zijlstra <peterz@infradead.org>
Date: Thu, 15 Mar 2012 12:13:34 +0100
In-Reply-To: <4F61CD63.4090007@parallels.com>
References: <1331325556-16447-1-git-send-email-ssouhlal@FreeBSD.org>
	 <1331325556-16447-3-git-send-email-ssouhlal@FreeBSD.org>
	 <4F5C5E54.2020408@parallels.com>
	 <20120313152446.28b0d696.kamezawa.hiroyu@jp.fujitsu.com>
	 <4F5F236A.1070609@parallels.com>
	 <20120314091526.3c079693.kamezawa.hiroyu@jp.fujitsu.com>
	 <4F608F25.3010700@parallels.com> <4F613C5B.8030304@jp.fujitsu.com>
	 <4F61CD63.4090007@parallels.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Glauber Costa <glommer@parallels.com>
Cc: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Suleiman Souhlal <ssouhlal@FreeBSD.org>, cgroups@vger.kernel.org, suleiman@google.com, penberg@kernel.org, cl@linux.com, yinghan@google.com, hughd@google.com, gthelen@google.com, dan.magenheimer@oracle.com, hannes@cmpxchg.org, mgorman@suse.de, James.Bottomley@HansenPartnership.com, linux-mm@kvack.org, devel@openvz.org, linux-kernel@vger.kernel.org

On Thu, 2012-03-15 at 15:07 +0400, Glauber Costa wrote:
> But since I never heard of any machine with
> 9223372036854775807 bytes of memory, that is true even for the root memcg=
=20

What, you don't have more than 8 exabyte of memory in your laptop !?
Surely you're due for an upgrade then.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
