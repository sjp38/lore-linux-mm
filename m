Received: from 205-158-62-68.outblaze.com (205-158-62-68.outblaze.com [205.158.62.68])
	by spf13.us4.outblaze.com (Postfix) with QMQP id 3F3091856739
	for <linux-mm@kvack.org>; Mon, 23 Jun 2003 11:41:18 +0000 (GMT)
Message-ID: <20030623114112.7477.qmail@linuxmail.org>
Content-Type: text/plain; charset="iso-8859-1"
Content-Disposition: inline
Content-Transfer-Encoding: 7bit
MIME-Version: 1.0
From: "Zero Damager" <hemical-ass@linuxmail.org>
Date: Mon, 23 Jun 2003 12:41:12 +0100
Subject: Alex_
Sender: owner-linux-mm@kvack.org
Return-Path: <owner-linux-mm@kvack.org>
To: linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>

Does any body can help me? I'm looking for a people
who knows gas(gnu assemmbler) very good.
I need some body who can explain me what this peace of code
ripped with objdump program means --
//---------------------------------------------------------
 0xc8000412  ff fc ff ff ff ff  call <0xc8000400+13>
//---------------------------------------------------------

I have bit of experience with assemmbling, and byte code i understand to.
After the call instruction the processor begins code execution at address
0xc8000413, which is (fc) byte, it is some sort of clear-flag instruction,
then the (ff) byte follows, which means call instruction.
The question is -- where it jumps>? To (ff ff ff) address of the page>?
....
-- 
______________________________________________
http://www.linuxmail.org/
Now with e-mail forwarding for only US$5.95/yr

Powered by Outblaze
--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"aart@kvack.org"> aart@kvack.org </a>
