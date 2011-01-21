Return-Path: <owner-linux-mm@kvack.org>
Received: from mail202.messagelabs.com (mail202.messagelabs.com [216.82.254.227])
	by kanga.kvack.org (Postfix) with SMTP id 4B6E68D0069
	for <linux-mm@kvack.org>; Thu, 20 Jan 2011 22:12:42 -0500 (EST)
Date: Thu, 20 Jan 2011 22:12:39 -0500 (EST)
From: CAI Qian <caiqian@redhat.com>
Message-ID: <1949676939.98607.1295579559013.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
In-Reply-To: <1607793457.82870.1295506273461.JavaMail.root@zmail06.collab.prod.int.phx2.redhat.com>
Subject: Re: ksm/thp/memcg bug
MIME-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
To: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Cc: linux-mm <linux-mm@kvack.org>, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>


> > Or apply pathces I sent ? (As Nishimura-san pointed out.)
> I'll try them.
After applied those patches, the problem goes away.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom policy in Canada: sign http://dissolvethecrtc.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
