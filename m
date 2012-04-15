Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx186.postini.com [74.125.245.186])
	by kanga.kvack.org (Postfix) with SMTP id 89CB26B004A
	for <linux-mm@kvack.org>; Sun, 15 Apr 2012 07:37:49 -0400 (EDT)
Message-ID: <1334489838.28150.4.camel@twins>
Subject: Re: [Lsf] [RFC] writeback and cgroup
From: Peter Zijlstra <peterz@infradead.org>
Date: Sun, 15 Apr 2012 13:37:18 +0200
In-Reply-To: <20120412203719.GL2207@redhat.com>
References: <20120403183655.GA23106@dhcp-172-17-108-109.mtv.corp.google.com>
	 <20120404145134.GC12676@redhat.com> <20120407080027.GA2584@quack.suse.cz>
	 <20120410180653.GJ21801@redhat.com> <20120410210505.GE4936@quack.suse.cz>
	 <20120410212041.GP21801@redhat.com> <20120410222425.GF4936@quack.suse.cz>
	 <20120411154005.GD16692@redhat.com> <20120411192231.GF16008@quack.suse.cz>
	 <20120412203719.GL2207@redhat.com>
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: quoted-printable
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Vivek Goyal <vgoyal@redhat.com>
Cc: Jan Kara <jack@suse.cz>, ctalbott@google.com, rni@google.com, andrea@betterlinux.com, containers@lists.linux-foundation.org, linux-kernel@vger.kernel.org, lsf@lists.linux-foundation.org, linux-mm@kvack.org, jmoyer@redhat.com, lizefan@huawei.com, cgroups@vger.kernel.org, linux-fsdevel@vger.kernel.org

On Thu, 2012-04-12 at 16:37 -0400, Vivek Goyal wrote:
> If yes, how does one map a filesystem's bdi we want to put rules on?
>=20
/proc/self/mountinfo has the required bits

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
