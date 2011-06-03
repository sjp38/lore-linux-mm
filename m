Return-Path: <owner-linux-mm@kvack.org>
Received: from mail137.messagelabs.com (mail137.messagelabs.com [216.82.249.19])
	by kanga.kvack.org (Postfix) with SMTP id 15C4D8D003B
	for <linux-mm@kvack.org>; Fri,  3 Jun 2011 12:15:10 -0400 (EDT)
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <glkm-linux-mm-2@m.gmane.org>)
	id 1QSX1d-0004nN-Po
	for linux-mm@kvack.org; Fri, 03 Jun 2011 18:15:05 +0200
Received: from smtp.mgpi.de ([212.202.249.42])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 18:15:05 +0200
Received: from bheld by smtp.mgpi.de with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <linux-mm@kvack.org>; Fri, 03 Jun 2011 18:15:05 +0200
From: Bernhard Held <bheld@mgpi.de>
Subject: Re: KVM induced panic on 2.6.38[2367] & 2.6.39
Date: Fri, 03 Jun 2011 17:50:40 +0200
Message-ID: <isavsg$3or$1@dough.gmane.org>
References: <20110601011527.GN19505@random.random> <alpine.LSU.2.00.1105312120530.22808@sister.anvils> <4DE5DCA8.7070704@fnarfbargle.com> <4DE5E29E.7080009@redhat.com> <4DE60669.9050606@fnarfbargle.com> <4DE60918.3010008@redhat.com> <4DE60940.1070107@redhat.com> <4DE61A2B.7000008@fnarfbargle.com> <20110601111841.GB3956@zip.com.au> <4DE62801.9080804@fnarfbargle.com> <20110601230342.GC3956@zip.com.au> <4DE8E3ED.7080004@fnarfbargle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
In-Reply-To: <4DE8E3ED.7080004@fnarfbargle.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: linux-kernel@vger.kernel.org, kvm@vger.kernel.org, netdev@vger.kernel.org

Am 03.06.2011 15:38, schrieb Brad Campbell:
> On 02/06/11 07:03, CaT wrote:
>> On Wed, Jun 01, 2011 at 07:52:33PM +0800, Brad Campbell wrote:
>>> Unfortunately the only interface that is mentioned by name anywhere
>>> in my firewall is $DMZ (which is ppp0 and not part of any bridge).
>>>
>>> All of the nat/dnat and other horrible hacks are based on IP addresses.
>>
>> Damn. Not referencing the bridge interfaces at all stopped our host from
>> going down in flames when we passed it a few packets. These are two
>> of the oopses we got from it. Whilst the kernel here is .35 we got the
>> same issue from a range of kernels. Seems related.
>
> Well, I tried sending an explanatory message to netdev, netfilter & cc'd to kvm,
> but it appears not to have made it to kvm or netfilter, and the cc to netdev has
> not elicited a response. My resend to netfilter seems to have dropped into the
> bit bucket also.
Just another reference 3.5 months ago:
http://www.spinics.net/lists/netfilter-devel/msg17239.html

Bernhard

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
