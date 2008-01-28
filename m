Received: by fg-out-1718.google.com with SMTP id e12so1535939fga.4
        for <linux-mm@kvack.org>; Mon, 28 Jan 2008 00:31:43 -0800 (PST)
Message-ID: <6101e8c40801280031v1a860e90gfb3992ae5db37047@mail.gmail.com>
Date: Mon, 28 Jan 2008 09:31:43 +0100
From: "=?ISO-8859-1?Q?Oliver_Pinter_(Pint=E9r_Oliv=E9r)?="
	<oliver.pntr@gmail.com>
Subject: [2.6.24 REGRESSION] BUG: Soft lockup - with VFS
MIME-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Content-Disposition: inline
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: Linux Kernel <linux-kernel@vger.kernel.org>, linux-mm@kvack.org, linux-fsdevel@vger.kernel.org
List-ID: <linux-mm.kvack.org>

hi all!

in the 2.6.24 become i some soft lockups with usb-phone, when i pluged
in the mobile, then the vfs-layer crashed. am afternoon can i the
.config send, and i bisected the kernel, when i have time.

pictures from crash:
http://students.zipernowsky.hu/~oliverp/kernel/regression_2624/
-- 
Thanks,
Oliver

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
