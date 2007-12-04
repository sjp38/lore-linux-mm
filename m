Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by e2.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id lB4KSJv9030175
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 15:28:19 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id lB4KSJQ3130986
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 15:28:19 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id lB4KSJOT008521
	for <linux-mm@kvack.org>; Tue, 4 Dec 2007 15:28:19 -0500
Subject: Re: [RFC PATCH] LTTng instrumentation mm (updated)
From: Dave Hansen <haveblue@us.ibm.com>
In-Reply-To: <20071204200558.GB1988@Krystal>
References: <20071129023421.GA711@Krystal>
	 <1196317552.18851.47.camel@localhost> <20071130161155.GA29634@Krystal>
	 <1196444801.18851.127.camel@localhost> <20071130170516.GA31586@Krystal>
	 <1196448122.19681.16.camel@localhost> <20071130191006.GB3955@Krystal>
	 <y0mve7ez2y3.fsf@ton.toronto.redhat.com> <20071204192537.GC31752@Krystal>
	 <1196797259.6073.17.camel@localhost>  <20071204200558.GB1988@Krystal>
Content-Type: text/plain
Date: Tue, 04 Dec 2007 12:28:16 -0800
Message-Id: <1196800096.6073.25.camel@localhost>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Mathieu Desnoyers <mathieu.desnoyers@polymtl.ca>
Cc: "Frank Ch. Eigler" <fche@redhat.com>, akpm@linux-foundation.org, linux-kernel@vger.kernel.org, linux-mm@kvack.org, mbligh@google.com
List-ID: <linux-mm.kvack.org>

Or, think out of the box...

Maybe you can introduce some interfaces that expose information both in
sysfs (in normal human-readable formats) and in a way that lets you get
the same data out in some binary format.  

Seems to me you'll have a lot easier time justifying all of these lines
of code spread all over the kernel if there are a few more users off the
bat.  

-- Dave

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
