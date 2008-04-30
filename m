Date: Wed, 30 Apr 2008 11:01:39 -0700 (PDT)
From: Christoph Lameter <clameter@sgi.com>
Subject: Re: Warning on memory offline (and possible in usual migration?)
In-Reply-To: <20080430072620.GI27652@wotan.suse.de>
Message-ID: <Pine.LNX.4.64.0804301059570.26173@schroedinger.engr.sgi.com>
References: <20080414145806.c921c927.kamezawa.hiroyu@jp.fujitsu.com>
 <Pine.LNX.4.64.0804141044030.6296@schroedinger.engr.sgi.com>
 <20080422045205.GH21993@wotan.suse.de> <20080422165608.7ab7026b.kamezawa.hiroyu@jp.fujitsu.com>
 <20080422094352.GB23770@wotan.suse.de> <Pine.LNX.4.64.0804221215270.3173@schroedinger.engr.sgi.com>
 <20080423004804.GA14134@wotan.suse.de> <20080429162016.961aa59d.kamezawa.hiroyu@jp.fujitsu.com>
 <20080430065611.GH27652@wotan.suse.de> <20080430001249.c07ff5c8.akpm@linux-foundation.org>
 <20080430072620.GI27652@wotan.suse.de>
MIME-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Nick Piggin <npiggin@suse.de>
Cc: Andrew Morton <akpm@linux-foundation.org>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, "linux-mm@kvack.org" <linux-mm@kvack.org>, GOTO <y-goto@jp.fujitsu.com>
List-ID: <linux-mm.kvack.org>

One issue that I am still not clear on is (in particular for memory 
offline) is how exactly to determine if a page is under read I/O. I 
initially thought simply checking for PageUptodate would do the trick.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
