Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-wg0-f50.google.com (mail-wg0-f50.google.com [74.125.82.50])
	by kanga.kvack.org (Postfix) with ESMTP id B7C1D6B0035
	for <linux-mm@kvack.org>; Tue, 12 Aug 2014 01:00:57 -0400 (EDT)
Received: by mail-wg0-f50.google.com with SMTP id n12so9184087wgh.21
        for <linux-mm@kvack.org>; Mon, 11 Aug 2014 22:00:57 -0700 (PDT)
Received: from mtaout22.012.net.il (mtaout22.012.net.il. [80.179.55.172])
        by mx.google.com with ESMTP id v11si29353309wjr.176.2014.08.11.22.00.55
        for <linux-mm@kvack.org>;
        Mon, 11 Aug 2014 22:00:56 -0700 (PDT)
Received: from conversion-daemon.a-mtaout22.012.net.il by a-mtaout22.012.net.il (HyperSendmail v2007.08) id <0NA600B00GL0QU00@a-mtaout22.012.net.il> for linux-mm@kvack.org; Tue, 12 Aug 2014 08:00:55 +0300 (IDT)
Date: Tue, 12 Aug 2014 08:00:54 +0300
From: Oren Twaig <oren@scalemp.com>
Subject: x86: vmalloc and THP
Message-id: <53E99F86.5020100@scalemp.com>
MIME-version: 1.0
Content-type: text/html; charset=ISO-8859-1
Content-transfer-encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>, linux-mm@kvack.org
Cc: "Shai Fultheim (Shai@ScaleMP.com)" <Shai@scalemp.com>

<html style="direction: ltr;">
  <head>

    <meta http-equiv="content-type" content="text/html; charset=ISO-8859-1">
    <style type="text/css">body p { margin-bottom: 0cm; margin-top: 0pt; } </style>
  </head>
  <body style="direction: ltr;"
    bidimailui-detected-decoding-type="latin-charset" bgcolor="#FFFFFF"
    text="#000000">
    Hello,<br>
    <br>
    Does memory allocated using vmalloc() will be mapped using huge
    pages either directly or later by THP ? <br>
    <br>
    If not, is there any fast way to change this behavior ? Maybe by
    changing the granularity/alignment of such allocations to allow such
    mapping ?<br>
    <br>
    Thanks,<br>
    Oren Twaig.<br>
  
<br /><br />
<hr style='border:none; color:#909090; background-color:#B0B0B0; height: 1px; width: 99%;' />
<table style='border-collapse:collapse;border:none;'>
	<tr>
		<td style='border:none;padding:0px 15px 0px 8px'>
			<a href="http://www.avast.com/">
				<img border=0 src="http://static.avast.com/emails/avast-mail-stamp.png" />
			</a>
		</td>
		<td>
			<p style='color:#3d4d5a; font-family:"Calibri","Verdana","Arial","Helvetica"; font-size:12pt;'>
				This email is free from viruses and malware because <a href="http://www.avast.com/">avast! Antivirus</a> protection is active.
			</p>
		</td>
	</tr>
</table>
<br />
</body>
</html>

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
