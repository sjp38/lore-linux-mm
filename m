Return-Path: <owner-linux-mm@kvack.org>
Received: from psmtp.com (na3sys010amx160.postini.com [74.125.245.160])
	by kanga.kvack.org (Postfix) with SMTP id 4D9D06B005A
	for <linux-mm@kvack.org>; Sun,  8 Jan 2012 09:59:21 -0500 (EST)
Message-ID: <4F09AFBD.60503@suse.cz>
Date: Sun, 08 Jan 2012 16:01:17 +0100
From: Michal Marek <mmarek@suse.cz>
MIME-Version: 1.0
Subject: Re: [PATCH] Makefiles: Disable unused-variable warning
References: <1324695619-5537-1-git-send-email-kirill@shutemov.name> <20111227135752.GK5344@tiehlicka.suse.cz>
In-Reply-To: <20111227135752.GK5344@tiehlicka.suse.cz>
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Michal Hocko <mhocko@suse.cz>
Cc: "Kirill A. Shutemov" <kirill@shutemov.name>, linux-mm@kvack.org, cgroups@vger.kernel.org, linux-kernel@vger.kernel.org, containers@lists.linux-foundation.org, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, Balbir Singh <bsingharora@gmail.com>, Johannes Weiner <hannes@cmpxchg.org>, linux-kbuild@vger.kernel.org

Dne 27.12.2011 14:57, Michal Hocko napsal(a):
> Anyway, I am wondering why unused-but-set-variable is disabled while
> unused-variable is enabled.

unused-but-set-variable was disabled, because it was a new warning in
gcc 4.6 and produced too much noise relatively to its severity. A make
W=1 build of x86_64_defconfig gives:
$ grep -c 'Wunused-but-set-variable' log
77
$ grep -c 'Wunused-variable' log
0

More exotic configuration will probably result in a couple of unused
variable warnings, but that IMO no reason to disable them globally.

> Shouldn't we just disable it as well rather
> than workaround this in the code? The warning is just pure noise in this
> case.

If it's noise in a particular case, there is always the option to add

CFLAGS_memcontrol.o := $(call cc-disable-warning, unused-variable)

to the respective Makefile.

Michal

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
