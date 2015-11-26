Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f44.google.com (mail-wm0-f44.google.com [74.125.82.44])
	by kanga.kvack.org (Postfix) with ESMTP id 3F2E56B0038
	for <linux-mm@kvack.org>; Thu, 26 Nov 2015 16:56:44 -0500 (EST)
Received: by wmww144 with SMTP id w144so36795007wmw.0
        for <linux-mm@kvack.org>; Thu, 26 Nov 2015 13:56:43 -0800 (PST)
Received: from violet.fr.zoreil.com (violet.fr.zoreil.com. [2001:4b98:dc0:41:216:3eff:fe56:8398])
        by mx.google.com with ESMTPS id ot8si44071199wjc.163.2015.11.26.13.56.42
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 26 Nov 2015 13:56:43 -0800 (PST)
Date: Thu, 26 Nov 2015 22:56:39 +0100
From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 4.3+: Atheros ethernet fails after resume from s2ram, due to
 order 4 allocation
Message-ID: <20151126215638.GA22801@electric-eye.fr.zoreil.com>
References: <20151126163413.GA3816@amd>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <20151126163413.GA3816@amd>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Pavel Machek <pavel@ucw.cz>
Cc: kernel list <linux-kernel@vger.kernel.org>, jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org, "Rafael J. Wysocki" <rjw@rjwysocki.net>, linux-mm@kvack.org, nic-devel@qualcomm.com, ronangeles@gmail.com, ebiederm@xmission.com, David Miller <davem@davemloft.net>

Pavel Machek <pavel@ucw.cz> :
[...]
> Ok, so what went on is easy.. any ideas how to fix it ?

The driver should 1) prohibit holes in its receive ring, 2) allocate before
pushing data up in the stack 3) drop packets when it can't allocate a
fresh buffer and 4) stop releasing receive buffers - and any resource for
that matter - during suspend.

Really.

-- 
Ueimor

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
