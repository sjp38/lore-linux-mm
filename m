Received: from smtp3.akamai.com (vwall1.sanmateo.corp.akamai.com [172.23.1.71])
	by smtp3.akamai.com (8.12.10/8.12.10) with ESMTP id j0R6UVNX025611
	for <linux-mm@kvack.org>; Wed, 26 Jan 2005 22:30:32 -0800 (PST)
content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="iso-8859-1"
Content-Transfer-Encoding: 8BIT
Subject: RE: [patch] ptrace: unlocked access to last_siginfo (resending)
Date: Wed, 26 Jan 2005 22:30:10 -0800
Message-ID: <1CEE377DC97AED448AB93CF602C983E450F421@usca1ex-priv1.sanmateo.corp.akamai.com>
From: "Meda, Prasanna" <pmeda@akamai.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Roland McGrath <roland@redhat.com>
Cc: akpm@osdl.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>



>   That's correct.  Technically you don't need read_lock_irq, but just
>   spin_lock_irq, not that it really makes a difference.  Myself, I would
>   change that and also use struct assignment instead of memcpy.
>   But your patch is fine as it is.

Agreed, and I am going to preapre a patch based on your suggestions and
resend.

Thanks,
Prasanna
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
