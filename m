Return-Path: <owner-linux-mm@kvack.org>
Received: from mail143.messagelabs.com (mail143.messagelabs.com [216.82.254.35])
	by kanga.kvack.org (Postfix) with ESMTP id 762436B002D
	for <linux-mm@kvack.org>; Thu,  6 Oct 2011 19:03:51 -0400 (EDT)
Date: Thu, 6 Oct 2011 16:03:48 -0700
From: Larry Bassel <lbassel@codeaurora.org>
Subject: Re: [Xen-devel] Re: RFC -- new zone type
Message-ID: <20111006230348.GF7007@labbmf-linux.qualcomm.com>
References: <20110928180909.GA7007@labbmf-linux.qualcomm.comCAOFJiu1_HaboUMqtjowA2xKNmGviDE55GUV4OD1vN2hXUf4-kQ@mail.gmail.com>
 <c2d9add1-0095-4319-8936-db1b156559bf@default20111005165643.GE7007@labbmf-linux.qualcomm.com>
 <cc1256f9-4808-4d74-a321-6a3ec129cc05@default>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <cc1256f9-4808-4d74-a321-6a3ec129cc05@default>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Dan Magenheimer <dan.magenheimer@oracle.com>
Cc: Larry Bassel <lbassel@codeaurora.org>, linux-mm@kvack.org, Xen-devel@lists.xensource.com

Thanks for your answers to my questions. I have one more:

Will there be any problem if the memory I want to be
transcendent is highmem (i.e. doesn't have any permanent
virtual<->physical mapping)?

Thanks.

Larry

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
