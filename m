Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id OAA17845
	for <linux-mm@kvack.org>; Tue, 4 Mar 2003 14:13:13 -0800 (PST)
Date: Tue, 4 Mar 2003 14:09:18 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: 2.5.63-mm2
Message-Id: <20030304140918.4092f09b.akpm@digeo.com>
In-Reply-To: <1046815078.12931.79.camel@ibm-b>
References: <20030302180959.3c9c437a.akpm@digeo.com>
	<1046815078.12931.79.camel@ibm-b>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mark Wong <markw@osdl.org>
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Mark Wong <markw@osdl.org> wrote:
>
> It appears something is conflicting with the old Adapatec AIC7xxx.  My
> system halts when it attempts to probe the devices (I think it's that.) 
> So I started using the new AIC7xxx driver and all is well.  I don't see
> any messages to the console that points to any causes.  Is there
> someplace I can look for a clue to the problem?
> 
> I actually didn't realize I was using the old driver and have no qualms
> about not using it, but if it'll help someone else, I can help gather
> information.

There are "fixes" in that driver in Linus's tree.  I suggest you revert to
the 2.5.63 version of aic7xxx_old.c, see if that fixes it.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
