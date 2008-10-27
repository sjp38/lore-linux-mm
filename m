Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.1/8.13.1) with ESMTP id m9RHHRGQ016872
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:17:27 GMT
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m9RHHRE8618556
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:17:27 GMT
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m9RHHQXc032099
	for <linux-mm@kvack.org>; Mon, 27 Oct 2008 17:17:27 GMT
Subject: Re: [PATCH] memory hotplug: fix page_zone() calculation in
	test_pages_isolated()
From: Gerald Schaefer <gerald.schaefer@de.ibm.com>
In-Reply-To: <4905F114.3030406@de.ibm.com>
References: <4905F114.3030406@de.ibm.com>
Content-Type: text/plain
Date: Mon, 27 Oct 2008 18:17:26 +0100
Message-Id: <1225127846.20384.3.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: akpm@linux-foundation.org
Cc: linux-kernel@vger.kernel.org, linux-mm@kvack.org, schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com, kamezawa.hiroyu@jp.fujitsu.com, y-goto@jp.fujitsu.com
List-ID: <linux-mm.kvack.org>

Ouch, stupid Thunderbird broke the patch (or stupid me used Thunderbird...),
will send a new one.

Gerald


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
