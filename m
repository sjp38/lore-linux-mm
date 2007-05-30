Received: by an-out-0708.google.com with SMTP id d33so779743and
        for <linux-mm@kvack.org>; Tue, 29 May 2007 23:02:12 -0700 (PDT)
Message-ID: <2c09dd780705292302v55fba09q46efe6ff35587acd@mail.gmail.com>
Date: Wed, 30 May 2007 11:32:12 +0530
From: "manjunath k" <kmanjunat@gmail.com>
Subject: Dirty page count in statm
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Hi all,

  Ive been doing some work in the proc filesystem.
Ive noticed that the dirty pages count in the linux-2.6
kernel is always zero ( 0 ) in the /proc/<pid>/statm
information.

  Ive read the linux-2.6/Documentation/filesystem/proc.txt
wherein it says that the dirty pages count is alway 0 on
linux-2.6. I would like to know the reason for it.

Please give me some details about it.

-Thanks

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
