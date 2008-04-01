Received: by wf-out-1314.google.com with SMTP id 25so2307105wfc.11
        for <linux-mm@kvack.org>; Tue, 01 Apr 2008 01:54:46 -0700 (PDT)
Message-ID: <804dabb00804010154t1aec08b3y3add0117fd409748@mail.gmail.com>
Date: Tue, 1 Apr 2008 16:54:46 +0800
From: "Peter Teoh" <htmldeveloper@gmail.com>
Subject: RFC: swaptrace tool
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Kernel Newbies <kernelnewbies@nl.linux.org>, linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Go through this:

http://linux-mm.org/LinuxMMProjects

and u find there is no swaptrace.   What I want is a visualization of
how the swap is being use.   So once the operation is started, all
swap operation will be immediately written to an area in memory,
showing how the swap is written - the destination begin offset /
destination end offset/size info, and by what process/task - and its
correspond source begin offset, and source end offset.   The data
content itself will not be recorded.   Then after some time, via
ioctl() control, it will be stopped, and all that have been written to
memory will be flushed out to a file.   This flushing to external file
only take place after the data collection has stopped, otherwise, the
swap operations itself will affect the behavior of the swap, thus
rendering the data collection invalid.

The purpose of this trace is to see/oberver how the swap is being
used, whether any algor can help to cluster the swap together so as to
enhance swap batch processing etc.

Any comment on this idea?   Will it be useful?

-- 
Regards,
Peter Teoh

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
