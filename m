Received: from dredd.mcom.com (dredd.mcom.com [205.217.237.54])
	by netscape.com (8.10.0/8.10.0) with ESMTP id g152KJ728174
	for <linux-mm@kvack.org>; Mon, 4 Feb 2002 18:20:20 -0800 (PST)
Received: from netscape.com ([10.0.197.58]) by dredd.mcom.com
          (Netscape Messaging Server 4.15) with ESMTP id GR1FTV00.PCV for
          <linux-mm@kvack.org>; Mon, 4 Feb 2002 18:20:19 -0800
Message-ID: <3C5F418C.6030808@netscape.com>
Date: Mon, 04 Feb 2002 18:21:00 -0800
From: dp@netscape.com (Suresh Duddi)
MIME-Version: 1.0
Subject: .Help with measuring working-set
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

hi, I am developer of Mozilla (open source web browser from mozilla.org) 
We are trying to make footprint improvements to the browser and have 
settled on minimizing working set and max-vm-usage as our goals.

http://www.mozilla.org/projects/footprint/footprint-guide.html

One thing we are struggling with is measurement of working set of app 
during a time interval.

Any pointers ? Are the metrics the best ones to measure and optimize ?

This is my first post to this mailing list; deeply sorry if this 
question is outside the agenda of this group.

dp

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/
