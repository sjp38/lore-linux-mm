Subject: Re: swapping and the value of /proc/sys/vm/swappiness
From: Alan Cox <alan@lxorguk.ukuu.org.uk>
In-Reply-To: <36100000.1094677832@flay>
References: <5860000.1094664673@flay>
	 <Pine.LNX.4.44.0409081403500.23362-100000@chimarrao.boston.redhat.com>
	 <20040908215008.10a56e2b.diegocg@teleline.es>  <36100000.1094677832@flay>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Message-Id: <1094682510.12371.25.camel@localhost.localdomain>
Mime-Version: 1.0
Date: Wed, 08 Sep 2004 23:28:42 +0100
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Martin J. Bligh" <mbligh@aracnet.com>
Cc: Diego Calleja <diegocg@teleline.es>, Rik van Riel <riel@redhat.com>, raybry@sgi.com, marcelo.tosatti@cyclades.com, kernel@kolivas.org, akpm@osdl.org, Linux Kernel Mailing List <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, piggin@cyberone.com.au
List-ID: <linux-mm.kvack.org>

On Mer, 2004-09-08 at 22:10, Martin J. Bligh wrote:
> I really don't see any point in pushing the self-tuning of the kernel out
> into userspace. What are you hoping to achieve?

What if there is more than one right answer to "self-tune" policy. Also
what if you want an application to tweak the tuning in ways that are
different to general policy ?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
