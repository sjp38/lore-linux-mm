Received: from digeo-nav01.digeo.com (digeo-nav01.digeo.com [192.168.1.233])
	by packet.digeo.com (8.9.3+Sun/8.9.3) with SMTP id QAA23069
	for <linux-mm@kvack.org>; Tue, 4 Mar 2003 16:05:45 -0800 (PST)
Date: Tue, 4 Mar 2003 16:01:50 -0800
From: Andrew Morton <akpm@digeo.com>
Subject: Re: [PATCH] remove __pte_offset
Message-Id: <20030304160150.7d67e011.akpm@digeo.com>
In-Reply-To: <3E653D69.8000007@us.ibm.com>
References: <3E653012.5040503@us.ibm.com>
	<3E6530B3.2000906@us.ibm.com>
	<20030304181002.A16110@redhat.com>
	<629570000.1046819361@flay>
	<20030304182652.B16110@redhat.com>
	<3E653D69.8000007@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Dave Hansen <haveblue@us.ibm.com>
Cc: bcrl@redhat.com, mbligh@aracnet.com, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Dave Hansen <haveblue@us.ibm.com> wrote:
>
> While we're on the subject, does anyone else find the p*_offset
> functions confusing?

How about sticking nice comments over them, rather than rampant renamings?

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org">aart@kvack.org</a>
