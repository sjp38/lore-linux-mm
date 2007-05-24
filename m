Received: from sd0112e0.au.ibm.com (d23rh903.au.ibm.com [202.81.18.201])
	by ausmtp05.au.ibm.com (8.13.8/8.13.8) with ESMTP id l4O83JKu7561276
	for <linux-mm@kvack.org>; Thu, 24 May 2007 18:03:19 +1000
Received: from d23av02.au.ibm.com (d23av02.au.ibm.com [9.190.250.243])
	by sd0112e0.au.ibm.com (8.13.8/8.13.8/NCO v8.3) with ESMTP id l4O850b1126724
	for <linux-mm@kvack.org>; Thu, 24 May 2007 18:05:05 +1000
Received: from d23av02.au.ibm.com (loopback [127.0.0.1])
	by d23av02.au.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l4O80KZp014532
	for <linux-mm@kvack.org>; Thu, 24 May 2007 18:00:38 +1000
Message-ID: <4655460D.8070901@linux.vnet.ibm.com>
Date: Thu, 24 May 2007 13:30:13 +0530
From: Balbir Singh <balbir@linux.vnet.ibm.com>
Reply-To: balbir@linux.vnet.ibm.com
MIME-Version: 1.0
Subject: Re: RSS controller v2 Test results (lmbench )
References: <464C95D4.7070806@linux.vnet.ibm.com> <20070517112357.7adc4763.akpm@linux-foundation.org>  <4651B4BF.9040608@sw.ru> <4655407A.4090104@linux.vnet.ibm.com> <6599ad830705240039p10574207maca62b8c44825db7@mail.gmail.com>
In-Reply-To: <6599ad830705240039p10574207maca62b8c44825db7@mail.gmail.com>
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Paul Menage <menage@google.com>
Cc: Kirill Korotaev <dev@sw.ru>, Andrew Morton <akpm@linux-foundation.org>, Pavel Emelianov <xemul@sw.ru>, devel@openvz.org, Linux Containers <containers@lists.osdl.org>, linux kernel mailing list <linux-kernel@vger.kernel.org>, Linux Memory Management List <linux-mm@kvack.org>, Vaidyanathan Srinivasan <svaidy@linux.vnet.ibm.com>, "Eric W. Biederman" <ebiederm@xmission.com>, Herbert Poetzl <herbert@13thfloor.at>
List-ID: <linux-mm.kvack.org>

Paul Menage wrote:
> On 5/24/07, Balbir Singh <balbir@linux.vnet.ibm.com> wrote:
>> Kirill Korotaev wrote:
>> >> Where do we stand on all of this now anyway?  I was thinking of
>> getting Paul's
>> >> changes into -mm soon, see what sort of calamities that brings about.
>> > I think we can merge Paul's patches with *interfaces* and then
>> switch to
>> > developing/reviewing/commiting resource subsytems.
>> > RSS control had good feedback so far from a number of people
>> > and is a first candidate imho.
>> >
>>
>> Yes, I completely agree!
>>
> 
> I'm just finishing up the latest version of my container patches -
> hopefully sending them out tomorrow.
> 
> Paul

Thats good news! As I understand Kirill wanted to get your patches
in -mm and then get the RSS controller as the first candidate in
that uses the containers interfaces and I completely agree with
that approach.

-- 
	Warm Regards,
	Balbir Singh
	Linux Technology Center
	IBM, ISTL

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
