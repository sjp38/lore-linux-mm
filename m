Date: Fri, 17 Nov 2006 14:05:13 +0000
From: Alan <alan@lxorguk.ukuu.org.uk>
Subject: Re: [ckrm-tech] [RFC][PATCH 5/8] RSS controller task migration
 support
Message-ID: <20061117140513.07da6fd9@localhost.localdomain>
In-Reply-To: <20061117132533.A5FCF1B6A2@openx4.frec.bull.fr>
References: <20061117132533.A5FCF1B6A2@openx4.frec.bull.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: "Patrick.Le-Dot" <Patrick.Le-Dot@bull.net>
Cc: balbir@in.ibm.com, ckrm-tech@lists.sourceforge.net, dev@openvz.org, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, linux-mm@kvack.org, rohitseth@google.com
List-ID: <linux-mm.kvack.org>

On Fri, 17 Nov 2006 14:25:33 +0100 (CET)
> For a customer the main reason to use guarantee is to be sure that
> some pages of a job remain in memory when the system is low on free
> memory. This should be true even for a job in group/container A with

That actually doesn't appear a very useful definition.

There are two reasons for wanting memory guarantees

#1	To be sure a user can't toast the entire box but just their own
	compartment (eg web hosting)

#2	To ensure all apps continue to make progress

The simple approach doesn't seem to work for either. There is a threshold
above which #1 and #2 are the same thing, below that trying to keep a few
pages in memory will thrash not make progress and will harm overall
behaviour thus failing to solve #1 or #2. At that point you have to
decide whether what you have is a misconfiguration or whether the system
should be prepared to do temporary cycling overcommits so containers take
it in turn to make progress when overcommitted.

> If the limit is a "hard limit" then we have implemented reservation and
> this is too strict.

Thats fundamentally a judgement based on your particular workload and
constraints. If I am web hosting then I don't generally care if my end
users compartment blows up under excess load, I care that the other 200
customers using the box don't suffer and all phone me to complain.

Alan

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
