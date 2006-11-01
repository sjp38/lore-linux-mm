Message-ID: <45485541.6060700@openvz.org>
Date: Wed, 01 Nov 2006 11:05:21 +0300
From: Pavel Emelianov <xemul@openvz.org>
MIME-Version: 1.0
Subject: Re: [ckrm-tech] RFC: Memory Controller
References: <20061030103356.GA16833@in.ibm.com> <4545D51A.1060808@in.ibm.com> <4546212B.4010603@openvz.org> <454638D2.7050306@in.ibm.com> <45470DF4.70405@openvz.org> <45472B68.1050506@in.ibm.com> <4547305A.9070903@openvz.org> <Pine.LNX.4.64N.0610312158240.18766@attu4.cs.washington.edu>
In-Reply-To: <Pine.LNX.4.64N.0610312158240.18766@attu4.cs.washington.edu>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: David Rientjes <rientjes@cs.washington.edu>
Cc: Pavel Emelianov <xemul@openvz.org>, balbir@in.ibm.com, vatsa@in.ibm.com, dev@openvz.org, sekharan@us.ibm.com, ckrm-tech@lists.sourceforge.net, haveblue@us.ibm.com, linux-kernel@vger.kernel.org, pj@sgi.com, matthltc@us.ibm.com, dipankar@in.ibm.com, rohitseth@google.com, menage@google.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

David Rientjes wrote:
> On Tue, 31 Oct 2006, Pavel Emelianov wrote:
> 
>> Paul Menage won't agree. He believes that interface must come first.
>> I also remind you that the latest beancounter patch provides all the
>> stuff we're discussing. It may move tasks, limit all three resources
>> discussed, reclaim memory and so on. And configfs interface could be
>> attached easily.
>>
> 
> There's really two different interfaces: those to the controller and those 
> to the container.  While the configfs (or simpler fs implementation solely 
> for our purposes) is the most logical because of its inherent hierarchial 
> nature, it seems like the only criticism on that has come from UBC.  From 
> my understanding of beancounter, it could be implemented on top of any 
> such container abstraction anyway.

beancounters may be implemented above any (or nearly any) userspace
interface, no questions. But we're trying to come to agreement here,
so I just say my point of view.

I don't mind having file system based interface, I just believe that
configfs is not so good for it. I've already answered that having
our own filesystem for it sounds better than having configfs.

Maybe we can summarize what we have come to?

> 		David
> 

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
