Received: from masoud.ir (h135s108a129n47.user.nortelnetworks.com [47.129.108.135])
	(authenticated bits=0)
	by deimos.masoud.ir (8.13.4/8.13.3) with ESMTP id j57JGhQM010750
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <linux-mm@kvack.org>; Tue, 7 Jun 2005 15:16:43 -0400 (EDT)
Message-ID: <42A5F291.5020301@masoud.ir>
Date: Tue, 07 Jun 2005 15:16:33 -0400
From: Masoud Sharbiani <masouds@masoud.ir>
MIME-Version: 1.0
Subject: rmap patches for 2.4.30(amd 31)
Content-Type: multipart/mixed;
 boundary="------------060906010407090706090402"
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

This is a multi-part message in MIME format.
--------------060906010407090706090402
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Hello all,

I've posted the message below to linux-kernel@ and got no response.
Would someone be kind enough and take a look at this?  In particular, 
what is the standard test for memory manager tests/patches?
cheers,
Masoud


--------------060906010407090706090402
Content-Type: message/rfc822;
 name="rmap patches for 2.4.30(or 31)"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="rmap patches for 2.4.30(or 31)"

Return-Path: <linux-kernel-owner+masouds=40masoud.ir-S261164AbVFCWxf@vger.kernel.org>
Received: from vger.kernel.org (vger.kernel.org [12.107.209.244])
	by deimos.masoud.ir (8.13.4/8.13.3) with ESMTP id j53Msp7K012690
	for <masouds@masoud.ir>; Fri, 3 Jun 2005 18:54:51 -0400 (EDT)
Received: (majordomo@vger.kernel.org) by vger.kernel.org via listexpand
	id S261164AbVFCWxf (ORCPT <rfc822;masouds@masoud.ir>);
	Fri, 3 Jun 2005 18:53:35 -0400
Received: (majordomo@vger.kernel.org) by vger.kernel.org id S261165AbVFCWxf
	(ORCPT <rfc822;linux-kernel-outgoing>);
	Fri, 3 Jun 2005 18:53:35 -0400
Received: from CPE000625dddb50-CM000a73996061.cpe.net.cable.rogers.com ([70.28.15.40]:13901
	"EHLO deimos.masoud.ir") by vger.kernel.org with ESMTP
	id S261164AbVFCWxd (ORCPT <rfc822;linux-kernel@vger.kernel.org>);
	Fri, 3 Jun 2005 18:53:33 -0400
Received: from [192.168.1.102] ([192.168.1.1])
	(authenticated bits=0)
	by deimos.masoud.ir (8.13.4/8.13.3) with ESMTP id j53MrECm024585
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO);
	Fri, 3 Jun 2005 18:53:19 -0400 (EDT)
Message-ID: <42A0DF51.2010809@axentra.net>
Date: Fri, 03 Jun 2005 15:53:05 -0700
From: Masoud Sharbiani <masouds@axentra.net>
User-Agent: Mozilla Thunderbird 1.0.2 (Windows/20050317)
X-Accept-Language: en-us, en
MIME-Version: 1.0
To: riel@surriel.com
CC: linux-kernel@vger.kernel.org
Subject: rmap patches for 2.4.30(or 31)
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Sender: linux-kernel-owner@vger.kernel.org
Precedence: bulk
X-Mailing-List: linux-kernel@vger.kernel.org

Hello Rik,

It seems that I have successfully hacked 2.4.25 rmap patch so that it 
applies cleanly to 2.4.30 (that is, it compiles, boots and runs great 
under normal conditions); How would I go for testing it and stress 
testing it? It does survive the make -j of kernel (with lots of swap), 
but, when I want to try and run ltp tests, it goes to a bad mood (i.e. 
swapping out massively at first, then a dead silence)

Here is my ltp test run command:
./runltplite.sh -i 1024 -m 128 -p -q -l /tmp/result-rmap -d /home/0tmp/
It ends up forking a lot of loadgen processes that simply allocate 
memory and use it (and CPU), so the system becomes unresponsive; It also 
starts killing processes since it runs out of memory. I don't see any 
hangs or panics, and the system responds to pings and Keyboard dump 
commands, such as right-Alt+Scroll lock and similar ones, and looks it 
is spending most of its time in page_launder() or thereabouts, swap and 
physical memory both become full.
How do you test the rmap patches for correctness before offering them to 
the people out there?
The patch is available from http://masoud.ir/patches/2.4.30-rmap15.patch

Thanks in advance,
Masoud Sharbiani

-
To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
Please read the FAQ at  http://www.tux.org/lkml/

--------------060906010407090706090402--

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
