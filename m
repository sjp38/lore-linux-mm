Date: Wed, 08 Sep 2004 16:42:14 -0700
From: "Martin J. Bligh" <mbligh@aracnet.com>
Subject: Re: swapping and the value of /proc/sys/vm/swappiness
Message-ID: <64810000.1094686934@flay>
In-Reply-To: <1094682510.12371.25.camel@localhost.localdomain>
References: <5860000.1094664673@flay> <Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com> <20040908215008.10a56e2b.diegocg@teleline.es>  <36100000.1094677832@flay> <1094682510.12371.25.camel@localhost.localdomain>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Cc: Diego Calleja <diegocg@teleline.es>, Rik van Riel <riel@redhat.com>, raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

> On Mer, 2004-09-08 at 22:10, Martin J. Bligh wrote:
>> I really don't see any point in pushing the self-tuning of the kernel out
>> into userspace. What are you hoping to achieve?
> 
> What if there is more than one right answer to "self-tune" policy. Also
> what if you want an application to tweak the tuning in ways that are
> different to general policy ?

It's still overridable from userspace, I'd think. But having a sensible
default in the kernel makes a crapload of sense to me. We have better
faster access to data from there - if there are really things that aren't
just parameters to the tuning algorithm it'd have to repeatedly poke 
values into hard overrides. Do-able, but not what we want by default,
I'd think.

M.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
