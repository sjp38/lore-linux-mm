Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with ESMTP id 6B5C06B006E
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 14:23:18 -0500 (EST)
Received: from /spool/local
	by e8.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <linux-mm@kvack.org> from <paulmck@linux.vnet.ibm.com>;
	Fri, 11 Nov 2011 14:23:16 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id pABJMEpX3080350
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 14:22:14 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id pABJMCLi002397
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 14:22:13 -0500
Date: Fri, 11 Nov 2011 11:22:11 -0800
From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: INFO: possible recursive locking detected: get_partial_node()
 on 3.2-rc1
Message-ID: <20111111192211.GE2283@linux.vnet.ibm.com>
Reply-To: paulmck@linux.vnet.ibm.com
References: <20111109090556.GA5949@zhy>
 <201111102335.06046.kernelmail.jms@gmail.com>
 <1320980671.22361.252.camel@sli10-conroe>
 <alpine.DEB.2.00.1111110857330.3557@router.home>
 <CAAVPGOPwKV12TqwU1DcxvJTW9dsmWNiNFg4ga7PzWNgQ2M=1RQ@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CAAVPGOPwKV12TqwU1DcxvJTW9dsmWNiNFg4ga7PzWNgQ2M=1RQ@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Julie Sullivan <kernelmail.jms@gmail.com>
Cc: Christoph Lameter <cl@linux.com>, Shaohua Li <shaohua.li@intel.com>, Yong Zhang <yong.zhang0@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

On Fri, Nov 11, 2011 at 07:09:01PM +0000, Julie Sullivan wrote:
> It's probably moot now but FWIW I checked Shaohua's patch too and it
> got rid of the warning in my dmesg.

Thank you both for your testing efforts!  Hopefully there will be
a more permanent fix soon.

							Thanx, Paul

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
