Subject: Re: 2.5.63-mm2
From: Mark Wong <markw@osdl.org>
In-Reply-To: <20030302180959.3c9c437a.akpm@digeo.com>
References: <20030302180959.3c9c437a.akpm@digeo.com>
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Date: 04 Mar 2003 13:57:57 -0800
Message-Id: <1046815078.12931.79.camel@ibm-b>
Mime-Version: 1.0
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Andrew Morton <akpm@digeo.com>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

It appears something is conflicting with the old Adapatec AIC7xxx.  My
system halts when it attempts to probe the devices (I think it's that.) 
So I started using the new AIC7xxx driver and all is well.  I don't see
any messages to the console that points to any causes.  Is there
someplace I can look for a clue to the problem?

I actually didn't realize I was using the old driver and have no qualms
about not using it, but if it'll help someone else, I can help gather
information.

-- 
Mark Wong - - markw@osdl.org
Open Source Development Lab Inc - A non-profit corporation
15275 SW Koll Parkway - Suite H - Beaverton OR, 97006
(503)-626-2455 x 32 (office)
(503)-626-2436      (fax)
http://www.osdl.org/archive/markw/

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
