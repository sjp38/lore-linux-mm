Date: Mon, 11 Jun 2007 20:40:46 +0200
From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: mm: memory/cpu hotplug section mismatch.
Message-ID: <20070611184046.GA6458@uranus.ravnborg.org>
References: <20070611043543.GA22910@linux-sh.org> <20070611140145.05726c0f.kamezawa.hiroyu@jp.fujitsu.com> <20070611050955.GA23215@linux-sh.org> <20070611082732.70018522.randy.dunlap@oracle.com> <20070611154428.GA27644@linux-sh.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20070611154428.GA27644@linux-sh.org>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Mundt <lethal@linux-sh.org>, Randy Dunlap <randy.dunlap@oracle.com>, KAMEZAWA Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>, linux-mm@kvack.org, linux-kernel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

> 
> If CONFIG_MEMORY_HOTPLUG=n __meminit == __init, and if
> CONFIG_HOTPLUG_CPU=n __cpuinit == __init. However, with one set and the
> other disabled, you end up with a reference between __init and a regular
> non-init function.

My plan is to define dedicated sections for both __devinit and __meminit.
Then we can apply the checks no matter the definition of CONFIG_HOTPLUG*
But we are a few steps away form doing so:
1) All harcoded uses of .init.text needs to go (at least done in assembler files)
2) The arch lds files needs to be unified a bit too.

Then we can during the final link stage decide if __devinit shall be merged
into .text or .init.text (after applying the modpost checks).

But do not hold your breath.

The even more important precondition is to sort out all the current
section mismatch warnings. But here we are getting close.

	Sam

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
