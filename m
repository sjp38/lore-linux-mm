Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wm0-f70.google.com (mail-wm0-f70.google.com [74.125.82.70])
	by kanga.kvack.org (Postfix) with ESMTP id F36C56B025E
	for <linux-mm@kvack.org>; Wed,  7 Dec 2016 13:42:40 -0500 (EST)
Received: by mail-wm0-f70.google.com with SMTP id m203so40314132wma.2
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 10:42:40 -0800 (PST)
Received: from mail-wj0-x244.google.com (mail-wj0-x244.google.com. [2a00:1450:400c:c01::244])
        by mx.google.com with ESMTPS id 9si9541393wmw.8.2016.12.07.10.42.39
        for <linux-mm@kvack.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Wed, 07 Dec 2016 10:42:39 -0800 (PST)
Received: by mail-wj0-x244.google.com with SMTP id j10so23967572wjb.3
        for <linux-mm@kvack.org>; Wed, 07 Dec 2016 10:42:39 -0800 (PST)
Date: Wed, 7 Dec 2016 21:42:36 +0300
From: "Kirill A. Shutemov" <kirill@shutemov.name>
Subject: Re: mlockall() with pid parameter
Message-ID: <20161207184236.GA5593@node.shutemov.name>
References: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
In-Reply-To: <CACKey4xEaMJ8qQyT7H5jQSxEBrxxuopg2a_AiMFJLeTTA+M9Lg@mail.gmail.com>
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: Federico Reghenzani <federico.reghenzani@polimi.it>
Cc: linux-mm@kvack.org

On Wed, Dec 07, 2016 at 04:39:13PM +0100, Federico Reghenzani wrote:
> Hello,
> 
> I'm working on Real-Time applications in Linux. `mlockall()` is a typical
> syscall used in RT processes in order to avoid page faults. However, the
> use of this syscall is strongly limited by ulimits, so basically all RT
> processes that want to call `mlockall()` have to be executed with root
> privileges.

For raising rlimits, you don't really need full root, only
CAP_SYS_RESOURCES (I'm not sure if it's any safer than full root in
practice).

It gives one other possible approach: set the capability for the binary.
Real-time proceses is already somewhat priviledged, right?
I mean CAP_SYS_NICE.

-- 
 Kirill A. Shutemov

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
