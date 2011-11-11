Return-Path: <owner-linux-mm@kvack.org>
Received: from mail6.bemta12.messagelabs.com (mail6.bemta12.messagelabs.com [216.82.250.247])
	by kanga.kvack.org (Postfix) with ESMTP id 5F27E6B002D
	for <linux-mm@kvack.org>; Fri, 11 Nov 2011 14:09:04 -0500 (EST)
Received: by gyg10 with SMTP id 10so4163821gyg.14
        for <linux-mm@kvack.org>; Fri, 11 Nov 2011 11:09:01 -0800 (PST)
MIME-Version: 1.0
In-Reply-To: <alpine.DEB.2.00.1111110857330.3557@router.home>
References: <20111109090556.GA5949@zhy>
	<201111102335.06046.kernelmail.jms@gmail.com>
	<1320980671.22361.252.camel@sli10-conroe>
	<alpine.DEB.2.00.1111110857330.3557@router.home>
Date: Fri, 11 Nov 2011 19:09:01 +0000
Message-ID: <CAAVPGOPwKV12TqwU1DcxvJTW9dsmWNiNFg4ga7PzWNgQ2M=1RQ@mail.gmail.com>
Subject: Re: INFO: possible recursive locking detected: get_partial_node() on 3.2-rc1
From: Julie Sullivan <kernelmail.jms@gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Christoph Lameter <cl@linux.com>
Cc: Shaohua Li <shaohua.li@intel.com>, Yong Zhang <yong.zhang0@gmail.com>, "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, Pekka Enberg <penberg@kernel.org>, "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>, Thomas Gleixner <tglx@linutronix.de>, "linux-mm@kvack.org" <linux-mm@kvack.org>

It's probably moot now but FWIW I checked Shaohua's patch too and it
got rid of the warning in my dmesg.
Cheers
Julie

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
