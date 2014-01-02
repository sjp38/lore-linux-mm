Return-Path: <owner-linux-mm@kvack.org>
Received: from mail-vc0-f169.google.com (mail-vc0-f169.google.com [209.85.220.169])
	by kanga.kvack.org (Postfix) with ESMTP id 0A3F96B0031
	for <linux-mm@kvack.org>; Thu,  2 Jan 2014 15:46:29 -0500 (EST)
Received: by mail-vc0-f169.google.com with SMTP id hu19so7485749vcb.0
        for <linux-mm@kvack.org>; Thu, 02 Jan 2014 12:46:29 -0800 (PST)
Received: from cdptpa-omtalb.mail.rr.com (cdptpa-omtalb.mail.rr.com. [75.180.132.120])
        by mx.google.com with ESMTP id uw4si23726227vec.1.2014.01.02.12.46.28
        for <linux-mm@kvack.org>;
        Thu, 02 Jan 2014 12:46:29 -0800 (PST)
Message-ID: <52C5D024.1020906@ubuntu.com>
Date: Thu, 02 Jan 2014 15:46:28 -0500
From: Phillip Susi <psusi@ubuntu.com>
MIME-Version: 1.0
Subject: readahead man page incorrectly says it blocks
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org, linux-fsdevel <linux-fsdevel@vger.kernel.org>

-----BEGIN PGP SIGNED MESSAGE-----
Hash: SHA1

The man page for readahead(2) incorrectly claims that it blocks until
all of the requested data has been read.  I filed a bug last year to
have this corrected, but I think it is being ignored now because they
don't believe me that it isn't supposed to block.  Could someone help
back me up and get this fixed?

https://bugzilla.kernel.org/show_bug.cgi?id=54271
-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.17 (MingW32)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iQEcBAEBAgAGBQJSxdAkAAoJEI5FoCIzSKrwA8MH/jNRBxTENfpaiB2qNpaxhv5i
FGj4mJ/VEhgntg6iCK7KN1r796GpnG+PI0yAEHcXHsHB2o9JoyB1jnaTUEte3PAb
anetZenfKHbq9pO5/5tYCLY8KX4pBp9xSI3G0SyeZ5aY5/jObj24jEswwViuYlvs
3Ma+zQxpcYnVht29NPhioUOmxBocJkvFleAemHrPydYb9Q6wuHYiIke61sjFYXYy
8sPHhuXfIb6W4NweHmI9RGhijfiRK8AjgUaGvmVx2CzQ5B0vfw0SmAfeMYodkwU5
7M+yyNCKn19IJSbALJ8E1BupHnhe2r3InRXLNfrWXy0JvkbgWFk+fAatkzIUpdQ=
=tZiw
-----END PGP SIGNATURE-----

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
