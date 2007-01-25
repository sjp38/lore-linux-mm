Date: Thu, 25 Jan 2007 14:19:44 +0900
From: KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
Subject: Re: [RFC] Limit the size of the pagecache
Message-Id: <20070125141944.67347aeb.kamezawa.hiroyu@jp.fujitsu.com>
In-Reply-To: <45B831DF.7080506@redhat.com>
References: <Pine.LNX.4.64.0701231645260.5239@schroedinger.engr.sgi.com>
	<20070124121318.6874f003.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0701232028520.6820@schroedinger.engr.sgi.com>
	<20070124141510.7775829c.kamezawa.hiroyu@jp.fujitsu.com>
	<20070125093259.74f76144.kamezawa.hiroyu@jp.fujitsu.com>
	<Pine.LNX.4.64.0701241841000.12325@schroedinger.engr.sgi.com>
	<20070125121254.a2e91875.kamezawa.hiroyu@jp.fujitsu.com>
	<45B831DF.7080506@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Rik van Riel <riel@redhat.com>
Cc: clameter@sgi.com, aubreylee@gmail.com, svaidy@linux.vnet.ibm.com, nickpiggin@yahoo.com.au, rgetz@blackfin.uclinux.org, Michael.Hennerich@analog.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

On Wed, 24 Jan 2007 23:28:15 -0500
Rik van Riel <riel@redhat.com> wrote:

> KAMEZAWA Hiroyuki wrote:
> 
> > FYI:
> > Because some customers are migrated from mainframes, they want to control
> > almost all features in OS, IOW, designing memory usages.
> 
> Don't you mean:
> 
> "Because some customers are migrating from mainframes, they are
>   used to needing to control all features in OS" ? :)
> 
Ah yes ;)
I always says Linux is different from mainframes.

--
Because some customers have been migrated from mainframes,
they expected that they could do what they did on mainframes.
They want to control almost all features in OS. But they can't now.
This means they can't use their experience and schemes from old days.
--

Because they are studying Linux now, the case may change in future, I think.


Thanks,
-Kame

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
