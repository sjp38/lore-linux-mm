Message-ID: <4547305A.9070903@openvz.org>
Date: Tue, 31 Oct 2006 14:15:38 +0300
From: Pavel Emelianov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [ckrm-tech] RFC: Memory Controller
References: <20061030103356.GA16833@in.ibm.com> <4545D51A.1060808@in.ibm.com> <4546212B.4010603@openvz.org> <454638D2.7050306@in.ibm.com> <45470DF4.70405@openvz.org> <45472B68.1050506@in.ibm.com>
In-Reply-To: <45472B68.1050506@in.ibm.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: balbir@in.ibm.com
Cc: Pavel Emelianov <xemul@openvz.org>, vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

[snip]

> That's like disabling memory over-commit in the regular kernel.

Nope. We limit only unreclaimable mappings. Allowing user
to break limits breaks the sense of limit.

Or you do not agree that allowing unlimited unreclaimable
mappings doesn't alow you the way to cut groups gracefully?

[snip]

> Please see the patching of Rohit's memory controller for user
> level patching. It seems much simpler.

Could you send me an URL where to get the patch from, please.
Or the patch itself directly to me. Thank you.

[snip]

> I would prefer a different set
> 
> 1 & 2, for now we could use any interface and then start developing the
> controller. As we develop the new controller, we are likely to find the
> need to add/enhance the interface, so freezing in on 1 & 2 might not be
> a good idea.

Paul Menage won't agree. He believes that interface must come first.
I also remind you that the latest beancounter patch provides all the
stuff we're discussing. It may move tasks, limit all three resources
discussed, reclaim memory and so on. And configfs interface could be
attached easily.

> I would put 4, 5 and 6 ahead of 3, based on the changes I see in Rohit's
> memory controller.
> 
> Then take up the rest.

I'll review Rohit's patches and comment.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
