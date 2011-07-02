Return-Path: <owner-linux-mm@kvack.org>
Received: from mail144.messagelabs.com (mail144.messagelabs.com [216.82.254.51])
	by kanga.kvack.org (Postfix) with SMTP id BB0346B0012
	for <linux-mm@kvack.org>; Sat,  2 Jul 2011 02:37:05 -0400 (EDT)
Message-ID: <4E0EBC7E.4090703@internode.on.net>
Date: Sat, 02 Jul 2011 16:06:46 +0930
From: Arthur Marsh <arthur.marsh@internode.on.net>
MIME-Version: 1.0
Subject: 0bda:2838 Ezcap DVB USB adaptor - no device files created
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Sender: owner-linux-mm@kvack.org
List-ID: <linux-mm.kvack.org>
To: linux-mm@kvack.org
Cc: Joel Stanley <joel@jms.id.au>

Hi, I bought one of these things having seen the Linux penguin on the 
box and compiled the code from the
http://jms.id.au/wiki/EzcapDvbAdapter web page on a quad core AMD64 
machine using 3.0.0-rc5 Linux kernel and GCC 4.6.1 under Debian sid.

On boot-up the device is at least partially recognised:

[    1.430924] usb 1-5: New USB device found, idVendor=0bda, idProduct=2838
[    1.431005] usb 1-5: Product: RTL2838UHIDIR
[    6.245292] IR NEC protocol handler initialized
[    6.284327] IR RC5(x) protocol handler initialized
[    6.338049] IR RC6 protocol handler initialized
[    6.371470] IR JVC protocol handler initialized
[    6.448155] IR Sony protocol handler initialized
[    6.590577] lirc_dev: IR Remote Control driver registered, major 252
[    6.591144] IR LIRC bridge handler initialized
[    7.085160] usbcore: registered new interface driver dvb_usb_rtl2832u


$ lsmod|grep dvb
dvb_usb_rtl2832u      111764  0
dvb_usb                18302  1 dvb_usb_rtl2832u
dvb_core               77682  1 dvb_usb
rc_core                18294  7 
dvb_usb,ir_lirc_codec,ir_sony_decoder,ir_jvc_decoder,ir_rc6_decoder,ir_rc5_decoder,ir_nec_decoder
i2c_core               23876  7 
dvb_usb,max6650,radeon,drm_kms_helper,drm,i2c_algo_bit,i2c_piix4
usbcore               119731  5 dvb_usb_rtl2832u,dvb_usb,ohci_hcd,ehci_hcd

but apparently no device files are created (there is no /dev/dvb tree).

Any suggestions for things to try to get this working welcome.

Regards,

Arthur.



--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Fight unfair telecom internet charges in Canada: sign http://stopthemeter.ca/
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
