content-class: urn:content-classes:message
MIME-Version: 1.0
Content-Type: text/plain;
	charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Subject: VM benchmarking help?
Date: Thu, 12 Feb 2004 08:25:45 -0800
Message-ID: <840273B2CF2C534E894D9705984C88F4930885@mail.corp.movaris.com>
From: "Kirk True" <ktrue@movaris.com>
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

Are there any resources that detail how to effectively benchmark the VM? How do I write test cases that are accurate and representative of certain usages? Under what environment(s) should these tests be run (e.g. is running under UML unhelpful?)? What metrics should be measured: time, number of faults, swapping, allocations, deallocations, etc.? What's the best format to report these findings and tweak them? Might a good first step might be to run other's test cases and provide more data points? If so, where can these tests - and directions on how to execute them - be found?

I'd like to help out but I need some guidance in doing so :)

Thanks!
Kirk
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
